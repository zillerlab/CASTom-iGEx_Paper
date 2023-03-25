library('data.table')
library('stringr')
library('argparse')
library('tidyverse')
library('igraph')

parser <- ArgumentParser(description="create sample file")
parser$add_argument("--outFold", type="character", default = "./", help = "path output")
parser$add_argument("--phenoFold", type="character", help = "path UKBB .tab files")
parser$add_argument("--ancestry", type="character", default = "Indian", help = "name ancestry considered")
parser$add_argument("--latest_sample_rm", type="character", help = "file with latest samples to remove")

args <- parser$parse_args()
outFold <- args$outFold
phenoFold <- args$phenoFold
ancestry <- args$ancestry
latest_sample_rm <- args$latest_sample_rm

##############
# phenoFold <- '/psycl/g/mpsziller/lucia/UKBB/phenotype_data/'
# outFold = "/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB_other_ancestry/"
# ancestry <- "Indian"
# latest_sample_rm <- "/psycl/g/mpsziller/lucia/UKBB/phenotype_data/w34217_20220222_sampleTOremove.csv"
##############

filed_id <- "21000" #ethnic backgroud: https://biobank.ctsu.ox.ac.uk/crystal/field.cgi?id=21000
data_coding <- read.table(sprintf("%scoding1001.tsv", outFold), h = T, stringsAsFactors = F, sep = '\t')
coding_id <- data_coding$coding[data_coding$meaning == ancestry]

# load phenotype table
phenoDat <- fread(sprintf('%sukb23895.tab', phenoFold), 
                  data.table=F, sep = '\t')

# extract samples id
id <- phenoDat[, sprintf("f.%s.0.0", filed_id)] == coding_id 
samples_id <- phenoDat[id & !is.na(id), "f.eid"]
latest_sample_rm <- read.csv(latest_sample_rm, h=F)
samples_id  <- setdiff(samples_id, latest_sample_rm$V1)
# get only those in sample imputation file
sample_imp <- read.table("/psycl/g/mpsukb/UKBB_hrc_imputation/ukb34217_imp_chr1_v3_s487317.sample", h=T, stringsAsFactors = F)
samples_id <- samples_id[samples_id %in% sample_imp$ID_1]

# load PCA and remove related individuals
PCA_table <- fread("/psycl/g/mpsukb/UKBB_hrc_imputation/ukb_sqc_v2_annotated_34217.txt", h=T, data.table = F)
samples_id <- intersect(samples_id, PCA_table$genoSample_ID)
PCA_table <- PCA_table[match(samples_id, PCA_table$genoSample_ID),]

# remove samples with discordant gender
id_rm <- PCA_table$Submitted_Gender != PCA_table$Inferred_Gender
PCA_table <- PCA_table[!id_rm, ]
samples_id <- PCA_table$genoSample_ID

relatives_tab <- fread('/psycl/g/mpsziller/lucia/UKBB/phenotype_data/ukb34217_rel_s488282.dat', h=T, 
                       stringsAsFactors=F)

# filter relatives based on samples in sample_ID
all_rel <- unique(c(relatives_tab$ID1, relatives_tab$ID2))
all_rel_filt <- all_rel[all_rel %in% samples_id]

relatives_tab_filt <- relatives_tab[relatives_tab$ID1 %in% all_rel_filt & relatives_tab$ID2 %in% all_rel_filt, ]
df <- relatives_tab_filt[, c('ID1', 'ID2', 'Kinship')]
graph_rel <- graph_from_data_frame(df, directed = F, vertices = NULL)
families <-  groups(components(graph_rel))

exclude <- vector(mode = 'list', length = length(families))
for(i in 1:length(families)){
  
  print(paste('family:', i))
  
  tmp <- families[[i]]
  
  if(length(tmp)>=100){
    exclude[[i]] <- c()
    # due to memory issue impossibile to compute, remove the most connected node and try again
    while(length(tmp)>=100){
      new_gr <- induced_subgraph(graph_rel, tmp)
      edges_V_f <- sapply(V(new_gr), function(x) length(incident(new_gr, x, mode='total')))
      rm_node <- names(which.max(edges_V_f))
      exclude[[i]] <- c(exclude[[i]], rm_node)
      new_fam <- setdiff(tmp, rm_node)
      graph_new_fam <- induced_subgraph(graph_rel, new_fam)
      new_fam_sub <- groups(components(graph_new_fam))
      
      id <- which(sapply(new_fam_sub, length)<100 & sapply(new_fam_sub, length)>1)
      if(length(id)>0){
        for(j in 1:length(id)){
          keep <- names(largest_ivs(induced_subgraph(graph_rel, new_fam_sub[[id[j]]]))[[1]])  
          exclude[[i]] <- c(exclude[[i]], setdiff(new_fam_sub[[id[j]]], keep))
        }
      }
      
      if(any(sapply(new_fam_sub, length)>=100)){
        tmp <- unlist(new_fam_sub[which(sapply(new_fam_sub, length)>=100)])
      }else{
        tmp <- 0
      }
      print(length(tmp))
    }
    
  }else{
    
    keep <- names(largest_ivs(induced_subgraph(graph_rel, tmp))[[1]])
    exclude[[i]] <- setdiff(families[[i]], keep)   
    
  }
}
exclude <- unlist(exclude)

# remove samples
PCA_table <- PCA_table[!PCA_table$genoSample_ID %in% exclude, ]
samples_id <- PCA_table$genoSample_ID

# add CAD info
CAD_pheno <- fread(sprintf("%sphenotypeMatrix_CAD.txt", outFold), data.table = F, h=T)
CAD_pheno <- CAD_pheno[match(samples_id , CAD_pheno$Individual_ID), ]
# save phenotype
CAD_pheno$Individual_ID <- paste0("X", CAD_pheno$Individual_ID)
write.table(file = sprintf("%sphenotypeMatrix_CAD_%s.txt", outFold, ancestry),
            x = CAD_pheno, quote = F, col.names = T, row.names = F, sep = "\t")
# save desription phenotype
pheno_desc <- data.frame(pheno_id = colnames(CAD_pheno)[-1],
                         FieldID = colnames(CAD_pheno)[-1], 
                         Field = colnames(CAD_pheno)[-1], 
                         Sexed = "Unisex", 
                         original_type = "CAT_SINGLE", 
                         transformed_type = "CAT_SINGLE_UNORDERED", 
                         nsamples = nrow(CAD_pheno), 
                         nsamples_T = colSums(CAD_pheno[, -1]), 
                         nsamples_F = colSums(CAD_pheno[, -1] == 0), stringsAsFactors = F)
write.table(file = sprintf("%sphenotypeDescription_CAD_%s.txt", outFold, ancestry),
            x = pheno_desc, quote = F, col.names = T, row.names = F, sep = "\t")

# save covariate file
covDat <- cbind(
  data.frame(genoSample_ID =	samples_id, 
             Individual_ID = CAD_pheno$Individual_ID, stringsAsFactors = F), 
  PCA_table[, paste0("PC", 1:10)], 
  data.frame(Gender =	PCA_table$Submitted_Gender,
             Dx = CAD_pheno$CAD_SOFT, stringsAsFactors = F))

covDat$Gender <- as.numeric(covDat$Gender == "F")
write.table(file = sprintf("%scovariateMatrix_latestW_202202_%s.txt", outFold, ancestry),
            x = covDat, quote = F, col.names = T, row.names = F, sep = "\t")

# save sample file for clustering
covDat_clust <- covDat
covDat_clust$Dx <- CAD_pheno$CAD_HARD
write.table(file = sprintf("%s/CAD_HARD_clustering/covariateMatrix_CADHARD_%s.txt", outFold, ancestry),
            x = covDat_clust, quote = F, col.names = T, row.names = F, sep = "\t")


