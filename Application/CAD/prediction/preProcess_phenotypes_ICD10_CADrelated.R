# extract CAD related phenotypes (ICD10-ICD9)
library('data.table')
library('stringr')

setwd('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB')

phenoDat_ICD <- fread('phenotypeMatrix_ICD9-10_OPCS4.txt', data.table=F, sep = '\t')
info_ICD <- fread('phenotypeDescription_manualproc_ICD9-10_OPCS4.txt', data.table=F, sep = '\t')

# consider only ICD10
FieldID <-  unique(info_ICD$FieldID[info_ICD$Field == 'Diagnoses - ICD10'])
tmp_info <- info_ICD[info_ICD$FieldID %in% FieldID, ]
tot_cod <- sapply(tmp_info$pheno_id, function(x) strsplit(x, split = '_')[[1]][2])

#### diabetes ####
id <- which(colnames(phenoDat_ICD) %in% paste(FieldID, tot_cod[grepl('E', tot_cod)], sep = '_'))
new_pheno <- phenoDat_ICD[, c(1,id)]
# save 
write.table(new_pheno, file = 'phenotypeMatrix_ICD10_Endocrine.txt', col.names = T, row.names = F, sep = '\t', quote = F)

#### circulatory ####
# I
id <- which(colnames(phenoDat_ICD) %in% paste(FieldID, tot_cod[grepl('I', tot_cod)], sep = '_'))
new_pheno <- phenoDat_ICD[, c(1,id)]
# save 
write.table(new_pheno, file = 'phenotypeMatrix_ICD10_Circulatory_system.txt', col.names = T, row.names = F, sep = '\t', quote = F)

#### respiratory ####
# J
id <- which(colnames(phenoDat_ICD) %in% paste(FieldID, tot_cod[grepl('J', tot_cod)], sep = '_'))
new_pheno <- phenoDat_ICD[, c(1,id)]
# save 
write.table(new_pheno, file = 'phenotypeMatrix_ICD10_Respiratory_system.txt', col.names = T, row.names = F, sep = '\t', quote = F)

#### blood patologies ####
id <- which(colnames(phenoDat_ICD) %in% paste(FieldID, tot_cod[grepl('D5', tot_cod) | grepl('D6', tot_cod)], sep = '_'))
new_pheno <- phenoDat_ICD[, c(1,id)]
# save 
write.table(new_pheno, file = 'phenotypeMatrix_ICD10_Anaemia.txt', col.names = T, row.names = F, sep = '\t', quote = F)


