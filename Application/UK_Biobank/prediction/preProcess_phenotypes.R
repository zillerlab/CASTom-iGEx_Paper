library('data.table')

setwd('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/')
phenoID <- c('23895', '38354')

covMat <- read.table('covariatesMatrix.txt', h=T,stringsAsFactors = F)

phenofile_list <- lapply(phenoID, function(x) fread(sprintf('ukb%s_filtered_britishWhiteUnrelated_pheno.tab', x), data.table=F, sep = '\t'))

tmp <- phenofile_list[[1]]
for(i in 2:length(phenofile_list)){
  
  tmp <- merge(x = tmp, y = phenofile_list[[i]], sort = F, by.x = 'userId', by.y = 'userId')
  
}

finalMat <- tmp[tmp$userId %in% covMat$genoSample_ID, ]

write.table('ukb_Key34217_filteredFinal_pheno.tab', x = finalMat, sep = '\t', quote = F, col.names = T, row.names = F)
