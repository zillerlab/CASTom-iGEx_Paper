library('data.table')

setwd('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/')
phenoID <- c('10089_HeightDer')

covMat <- read.table('covariatesMatrix_red_latestW.txt', h=T,stringsAsFactors = F)
phenofile_list <- lapply(phenoID, function(x) fread(sprintf('ukb%s_project25214_filtered_britishWhiteUnrelated_pheno.tab', x), data.table=F, sep = '\t'))
tmp <- phenofile_list[[1]]

coversion_id <- read.table('/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/samples_unrelated_ukb25214_ukb34217', h=T,stringsAsFactors = F)
# substitute new id
id <- match(tmp$userId, coversion_id$ukb25214)
print(identical(tmp$userId, coversion_id$ukb25214[id]))
tmp$userId <- coversion_id$ukb34217[id]

finalMat <- tmp[tmp$userId %in% covMat$genoSample_ID, ]

write.table(sprintf('ukb%s_filtered_britishWhiteUnrelated_pheno_final.tab', phenoID), x = finalMat, sep = '\t', quote = F, col.names = T, row.names = F)

