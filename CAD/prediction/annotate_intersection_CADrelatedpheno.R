# load all the phenotypes, check the intersection with the number of cases and controls (CAD)
# create a summary table specifing if the phenotype chould be considered or not

# use also ICD10-IC9-OPSC4
library(data.table)

phenoFold <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB'
pheno_info <- read.delim(sprintf('%s/phenotypeDescription_PHESANTproc_CADrelatedpheno.txt', phenoFold), h=T, stringsAsFactors = F, sep = '\t')
pheno_info_ICD <- read.delim(sprintf('%s/phenotypeDescription_manualproc_ICD9-10_OPCS4.txt', phenoFold), h=T, stringsAsFactors = F, sep = '\t')
# consider only main output
pheno_info_ICD <- pheno_info_ICD[pheno_info_ICD$Field %in% c('Diagnoses - ICD10', 'Diagnoses - ICD9', 'Operative procedures - OPCS4'),]
pheno_info <- rbind(pheno_info, pheno_info_ICD)

pheno_name <- read.table(sprintf('%s/name_CADrelatedpheno.txt', phenoFold), h=F, stringsAsFactors = F)$V1[-50]
pheno_CAD <- read.table(sprintf('%s/phenoMatrix.txt', phenoFold), h=T, stringsAsFactors = F, check.names = F)
pheno_info <- cbind(pheno_info, data.frame(pheno_type = rep(NA, nrow(pheno_info)), nsamples_CAD_SOFT_0 = rep(NA, nrow(pheno_info)), nsamples_CAD_SOFT_1 = rep(NA, nrow(pheno_info)),
                                           nsamples_CAD_SOFT_0_T = rep(NA, nrow(pheno_info)), nsamples_CAD_SOFT_1_T = rep(NA, nrow(pheno_info))))

for(i in 1:length(pheno_name)){
  
  print(pheno_name[i])
  
  tmp <- fread(sprintf('%s/phenotypeMatrix_%s.txt', phenoFold, pheno_name[i]), h=T, stringsAsFactors = F, check.names = F, sep = '\t', data.table = F)

  pheno_tmp <- pheno_info[pheno_info$pheno_id %in% colnames(tmp)[-1],]
  tmp <- cbind(tmp, pheno_CAD[match(tmp$Individual_ID, pheno_CAD$Individual_ID),'CAD_SOFT'])
  colnames(tmp)[ncol(tmp)] <- 'CAD_SOFT'
  
  pheno_info$pheno_type[pheno_info$pheno_id %in% colnames(tmp)[-1]] <- pheno_name[i]
  
  for(j in 1:nrow(pheno_tmp)){
    print(j)
    tmp_j <- tmp[, c(pheno_tmp$pheno_id[j], 'CAD_SOFT')]
    tmp_j <- tmp_j[!is.na(tmp_j[,1]),]
    
    if(pheno_tmp$transformed_type[j] %in% c('CAT_MUL_BINARY_VAR','CAT_SINGLE_UNORDERED', 'CAT_SINGLE_BINARY')){
      pheno_info$nsamples_CAD_SOFT_0_T[pheno_info$pheno_id == pheno_tmp$pheno_id[j]] <- length(which(tmp_j$CAD_SOFT == 0 & tmp_j[,1] == 1))
      pheno_info$nsamples_CAD_SOFT_1_T[pheno_info$pheno_id == pheno_tmp$pheno_id[j]] <- length(which(tmp_j$CAD_SOFT == 1  & tmp_j[,1] == 1))
    }
    
    pheno_info$nsamples_CAD_SOFT_0[pheno_info$pheno_id == pheno_tmp$pheno_id[j]] <- length(which(tmp_j$CAD_SOFT == 0))
    pheno_info$nsamples_CAD_SOFT_1[pheno_info$pheno_id == pheno_tmp$pheno_id[j]] <- length(which(tmp_j$CAD_SOFT == 1))
  }
  
}

# add a column stating if the phenotype should be kept or not
# parameters:
n_int_CAD <- 200 # minimum number of cases for that phenotype
n_int_CAD_T <- 100 # minimum number of TRUE samples intersection the cases for that phenotype

pheno_info$keep <- F
pheno_info$keep[pheno_info$nsamples_CAD_SOFT_1>=n_int_CAD & is.na(pheno_info$nsamples_CAD_SOFT_1_T)] <- T
pheno_info$keep[pheno_info$nsamples_CAD_SOFT_1>=n_int_CAD & !is.na(pheno_info$nsamples_CAD_SOFT_1_T) & pheno_info$nsamples_CAD_SOFT_1_T>=n_int_CAD_T] <- T

# save output
write.table(pheno_info, file = sprintf('%s/phenotypeDescription_PHESANTproc_CADrelatedpheno_annotated.txt', phenoFold), 
            col.names = T, row.names = F, quote = F, sep = '\t')

