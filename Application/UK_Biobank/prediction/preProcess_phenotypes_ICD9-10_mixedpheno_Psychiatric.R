# extract psychiatric considitons fro ICD9 and ICD10 and combine with self reported
library('data.table')
library('stringr')

setwd('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/')

phenoDat_ICD <- fread('phenotypeMatrix_ICD9-10_OPCS4.txt', data.table=F, sep = '\t')
phenoDat_selfRep <- fread('phenotypeMatrix_Medical_conditions.txt', data.table=F, sep = '\t')
info_ICD <- fread('phenotypeDescription_manualproc_ICD9-10_OPCS4.txt', data.table=F, sep = '\t')
info_tot <- fread('phenotypeDescription_PHESANTproc.txt', data.table=F, sep = '\t')

#### mental conditions ####
## ICD10: F00-F99
FieldID <-  unique(info_ICD$FieldID[info_ICD$Field == 'Diagnoses - ICD10'])
tmp_info <- info_ICD[info_ICD$FieldID %in% FieldID, ]
tot_cod <- sapply(tmp_info$pheno_id, function(x) strsplit(x, split = '_')[[1]][2])
cod <- unname(tot_cod[tot_cod %in% c(paste0('F0', 0:9), paste0('F', 10:99))])
id <- which(colnames(phenoDat_ICD) %in% paste(FieldID, cod, sep = '_'))

new_pheno <- phenoDat_ICD[, c(1,id)]
# save 
write.table(new_pheno, file = 'phenotypeMatrix_ICD10_Psychiatric.txt', col.names = T, row.names = F, sep = '\t', quote = F)

## ICD9: 290-319
FieldID <-  unique(info_ICD$FieldID[info_ICD$Field == 'Diagnoses - ICD9'])
tmp_info <- info_ICD[info_ICD$FieldID %in% FieldID, ]
tot_cod <- sapply(tmp_info$pheno_id, function(x) strsplit(x, split = '_')[[1]][2])
cod <- unname(tot_cod[tot_cod %in% 290:319])
id <- which(colnames(phenoDat_ICD) %in% paste(FieldID, cod, sep = '_'))

new_pheno <- phenoDat_ICD[, c(1,id)]
# save 
write.table(new_pheno, file = 'phenotypeMatrix_ICD9_Psychiatric.txt', col.names = T, row.names = F, sep = '\t', quote = F)

## combined
annDat <- read.csv('Annotation_psychiatric_disease.csv', h=T, stringsAsFactors=F)
tot_pheno <- merge(phenoDat_ICD, phenoDat_selfRep, by = 'Individual_ID', sort = F)
new_pheno <- data.frame(Individual_ID = tot_pheno$Individual_ID, stringsAsFactors = F)

for(i in 1:length(unique(annDat$Disease))){
  print(unique(annDat$Disease)[i])
  tmp <- annDat[annDat$Disease %in% unique(annDat$Disease)[i], ]
  pheno_tmp <- as.data.frame(tot_pheno[, colnames(tot_pheno) %in%  paste(tmp$Data_Field, tmp$Coding, sep = '_')])
  if(ncol(pheno_tmp)>0){
    if(ncol(pheno_tmp)>1){
      new_var <- rowSums(pheno_tmp)
      new_var[new_var>0] <- 1
    }else{
      new_var <- pheno_tmp
    }
    new_pheno <- cbind(new_pheno, new_var)
    colnames(new_pheno)[ncol(new_pheno)] <- unique(annDat$Disease)[i]
  }
}

write.table(new_pheno, file = 'phenotypeMatrix_mixedpheno_Psychiatric.txt', col.names = T, row.names = F, sep = '\t', quote = F)

# annotate
new_info <- data.frame(pheno_id=colnames(new_pheno)[-1], FieldID = NA, Field = NA, Path = NA, Strata = NA, 
                       Sexed = 'Unisex', Coding = NA, Coding_meaning = NA, original_type = 'CAT_SINGLE', 
                       transformed_type = 'CAT_SINGLE_UNORDERED', nsamples = 0, nsamples_T = 0, nsamples_F = 0, stringsAsFactors = F)

for(i in 1:nrow(new_info)){
  tmp <- annDat[annDat$Disease %in% new_info$pheno_id[i], ]
  new_info$FieldID[i] <- paste0(tmp$Data_Field, collapse='|')
  new_info$Field[i] <- paste0(tmp$Data_Field_Description, collapse='|')
  new_info$Coding_meaning[i] <- paste0(tmp$Description, collapse='|')
  new_info$nsamples[i] <- nrow(new_pheno)
  new_info$nsamples_T[i] <-  length(which(new_pheno[, i+1]==1))
  new_info$nsamples_F[i] <-  length(which(new_pheno[, i+1]==0))
}

new_info <- rbind(info_ICD[info_ICD$Field %in% c('Diagnoses - ICD10', 'Diagnoses - ICD9'),], new_info)
write.table(new_info, file ='phenotypeDescription_manualproc_ICD9-10_mixedpheno_Psychiatric.txt', col.names = T, row.names = F, sep = '\t', quote = F)



