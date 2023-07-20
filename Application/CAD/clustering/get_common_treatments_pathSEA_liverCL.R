library(dplyr)
library(data.table)

setwd("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/")
pathSEA_file <- "OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/pathSEA_corrPCs_tscoreClusterCases_featAssociation.txt"
medications_UKBB_info_file <- "INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_PHESANTproc_CADrelatedpheno_annotated.txt"
medications_UKBB_file <- "INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeMatrix_Medications.txt"
covDat_file <- "INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt"

pathSEA_out <- read.delim(pathSEA_file, h=T, stringsAsFactors = F)
medications_UKBB_info <- read.delim(medications_UKBB_info_file, h=T, stringsAsFactors = F)
medications_UKBB <- fread(medications_UKBB_file, h=T, stringsAsFactors = F, data.table = F)
covDat <- read.table(covDat_file, stringsAsFactors=F, sep = '\t', h=T)
covDat <- covDat[covDat$Dx == 1,]
covDat <- covDat[, colnames(covDat) %in% c('Individual_ID', 'Dx', paste0('PC',1:10), 'Age', 'Gender')]

drugs_name <- unique(pathSEA_out$drug)
medications_UKBB_info <- medications_UKBB_info %>% filter(Field %in% "Treatment/medication code")
medications_common <- intersect(medications_UKBB_info$Coding_meaning, drugs_name)
medications_common_id <- medications_UKBB_info$pheno_id[match(medications_common, 
                                                              medications_UKBB_info$Coding_meaning)]

medications_UKBB <- medications_UKBB[medications_UKBB$Individual_ID %in% covDat$Individual_ID, ]
medications_UKBB  <- medications_UKBB[, colnames(medications_UKBB) %in% c("Individual_ID", medications_common_id)]
keep_id <- which(colSums(medications_UKBB[, -1], na.rm=T) > 50)

if(length(keep_id)>0){
  medications_UKBB <- medications_UKBB[, c(1,keep_id + 1)]
}

medications_UKBB_info <- medications_UKBB_info[match(names(keep_id), medications_UKBB_info$pheno_id), ]
colnames(medications_UKBB)[-1] <- paste0("p", colnames(medications_UKBB)[-1])

for(i in 1:(ncol(medications_UKBB)-1)){
  
  tmp_covDat <- cbind(covDat, medications_UKBB[, i+1, drop = F])
  Coding_meaning <- medications_UKBB_info$Coding_meaning[i]
  write.table(x = tmp_covDat, 
              file = sprintf("INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/pathSEA/covariateMatrix_%s.txt", Coding_meaning), 
              quote = F, sep = '\t', col.names = T, row.names = F)
}

write.table(x = medications_UKBB_info, 
            file = sprintf("INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/pathSEA/phenotypeDescription_Covariates_tot.txt"), 
            quote = F, sep = '\t', col.names = T, row.names = F)
