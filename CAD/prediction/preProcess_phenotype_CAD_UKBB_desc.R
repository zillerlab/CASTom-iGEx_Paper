setwd('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/')

phenoDat <- read.table('phenoMatrix.txt', h=T, stringsAsFactors = F)

phenoDesc <- data.frame(pheno_id = colnames(phenoDat)[-1], FieldID = colnames(phenoDat)[-1], Field = colnames(phenoDat)[-1],Sexed = rep('Unisex',2),
                        original_type = rep('CAT_SINGLE',2), transformed_type = rep('CAT_SINGLE_UNORDERED',2), 
                        nsamples = rep(nrow(phenoDat),2), nsamples_T = apply(phenoDat[, -1], 2, function(x) length(which(x[!is.na(x)] == 1))), 
                        nsamples_F = apply(phenoDat[, -1], 2, function(x) length(which(x[!is.na(x)] == 0))))

write.table(file = 'phenotypeDescription_CAD.txt', x = phenoDesc, col.names = T, row.names = F, sep = '\t', quote = F)

