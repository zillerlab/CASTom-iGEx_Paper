library('data.table')

setwd('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/')
phenoID <- c('23895_BCratios')

covMat <- read.table('covariatesMatrix_red_latestW.txt', h=T,stringsAsFactors = F)

phenofile_list <- lapply(phenoID, function(x) fread(sprintf('ukb%s_filtered_britishWhiteUnrelated_pheno.tab', x), data.table=F, sep = '\t'))

tmp <- phenofile_list[[1]]
finalMat <- tmp[tmp$userId %in% covMat$genoSample_ID, ]

write.table(sprintf('ukb%s_filtered_britishWhiteUnrelated_pheno_final.tab', phenoID), x = finalMat, sep = '\t', quote = F, col.names = T, row.names = F)
