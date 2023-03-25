library('data.table')
library('stringr')
library('argparse')


parser <- ArgumentParser(description="extract CAD phenotype")
parser$add_argument("--phenoFold", type="character", help = "path UKBB .tab files")
parser$add_argument("--outFold", type="character", default = "./", help = "path output")

args <- parser$parse_args()
phenoFold <- args$phenoFold
outFold <- args$outFold

#####################################################
# convert phenoDat to the correct format:
# 2 type of phenotype CAD_HARD and CAD_SOFT
# based onn  Schunkert annotation
#####################################################

# phenoFold <- '/psycl/g/mpsziller/lucia/UKBB/phenotype_data/'

download.file("https://raw.githubusercontent.com/MRCIEU/PHESANT/master/variable-info/outcome-info.tsv", sprintf('%s/outcome-info.tsv', outFold))
expl_var <- sprintf('%s/outcome-info.tsv', outFold)

CAD_pheno_code_file <- paste0(outFold, c('phenotype_UKBB_CAD_Schunkert_HARD.csv', 'phenotype_UKBB_CAD_Schunkert_SOFT.csv'))
CAD_pheno_code <- lapply(CAD_pheno_code_file, function(x)  fread(x, data.table = F, h=F))

### function ###
get_annotation <- function(phenoDat, CAD_pheno_code, Field_name, sField_name) {
  
  pheno_id <- info$FieldID[info$Field == Field_name]
  tmp <- phenoDat[, grepl(paste0("f.", pheno_id), colnames(phenoDat))]
  code_id_CAD <- lapply(CAD_pheno_code, function(x) x$V1[x$V2 %in% sField_name])
  phenoDat_new <- data.frame(Individual_ID = phenoDat$f.eid, 
                              CAD_HARD = NA, 
                              CAD_SOFT = NA, 
                              stringsAsFactors = F)
  phenoDat_new$CAD_HARD <- as.numeric(apply(tmp, 1, function(x) any(x %in% code_id_CAD[[1]])))
  phenoDat_new$CAD_SOFT <- as.numeric(apply(tmp, 1, function(x) any(x %in% code_id_CAD[[2]])))
  
  return(phenoDat_new)
  
}

######## ICD9 ICD10 and OPSC4 original data (do not truncate code) ########
phenoDat <- fread(sprintf('%sukb39002.tab', phenoFold), 
                  data.table=F, sep = '\t')
phenoDat_self <- fread(sprintf('%sukb38354.tab', phenoFold), 
                       data.table=F, sep = '\t')
info <- fread(expl_var, data.table = F)

#### ICD9 ####
phenoDat_ICD9 <- get_annotation(phenoDat, CAD_pheno_code, 'Diagnoses - ICD9', 'ICD9')
#### ICD10 ####
phenoDat_ICD10 <- get_annotation(phenoDat, CAD_pheno_code, 'Diagnoses - ICD10', 'ICD10')
#### OPSC4 ####
phenoDat_OPCS4 <- get_annotation(phenoDat, CAD_pheno_code, 
                                 'Operative procedures - OPCS4', 'OPCS-4')


#### self-reported ####
phenoDat_illness <- get_annotation(phenoDat_self, CAD_pheno_code, 
                                   'Non-cancer illness code, self-reported', 
                                   'Non-cancer illness code, self-reported')
#### operation ####
phenoDat_operation <- get_annotation(phenoDat_self, CAD_pheno_code, 
                                     'Operation code', 
                                     'Operation code')

#### combine ####
common_id <- intersect(phenoDat$f.eid,  phenoDat_self$f.eid)
phenoDat_CAD <- data.frame(Individual_ID = common_id,
                           stringsAsFactors = F)

id <- match(common_id, phenoDat$f.eid)
id_self <- match(common_id, phenoDat_self$f.eid)

CAD_HARD <- phenoDat_ICD9$CAD_HARD[id] + 
            phenoDat_ICD10$CAD_HARD[id] + 
            phenoDat_OPCS4$CAD_HARD[id] +
            phenoDat_illness$CAD_HARD[id_self] +  
            phenoDat_operation$CAD_HARD[id_self]

CAD_SOFT <- phenoDat_ICD9$CAD_SOFT[id] + 
  phenoDat_ICD10$CAD_SOFT[id] + 
  phenoDat_OPCS4$CAD_SOFT[id] +
  phenoDat_illness$CAD_SOFT[id_self] +  
  phenoDat_operation$CAD_SOFT[id_self]

phenoDat_CAD$CAD_HARD <-  as.numeric(CAD_HARD > 0)
phenoDat_CAD$CAD_SOFT <-  as.numeric(CAD_SOFT > 0)


write.table(phenoDat_CAD, sprintf("%sphenotypeMatrix_CAD.txt", outFold), 
            quote = F, sep = "\t", col.names = T, row.names = F)



