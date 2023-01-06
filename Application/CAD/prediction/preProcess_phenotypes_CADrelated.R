library('data.table')

# filter to match covariate matrix and switch to ids ukb34217

setwd('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/')
phenoID <- c('10089', '22580', '40052')

covMat <- read.table('covariateMatrix.txt', h=T,stringsAsFactors = F)
phenofile_list <- lapply(phenoID, function(x) fread(sprintf('ukb%s_project25214_filtered_britishWhiteUnrelated_pheno.tab', x), data.table=F, sep = '\t'))
coversion_id <- read.table('/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/samples_unrelated_ukb25214_ukb34217', h=T,stringsAsFactors = F)

# substitute new id
for(i in 1:length(phenofile_list)){
  id <- match(phenofile_list[[i]]$userId, coversion_id$ukb25214)
  print(identical(phenofile_list[[i]]$userId, coversion_id$ukb25214[id]))
  phenofile_list[[i]]$userId <- coversion_id$ukb34217[id]
}

tmp <- phenofile_list[[1]]
for(i in 2:length(phenofile_list)){
  
  tmp <- merge(x = tmp, y = phenofile_list[[i]], sort = F, by.x = 'userId', by.y = 'userId')
  
}

finalMat <- tmp[tmp$userId %in% covMat$genoSample_ID, ]
write.table('ukb_Key34217_filteredFinal_phenoCADrelated.tab', x = finalMat, sep = '\t', quote = F, col.names = T, row.names = F)
