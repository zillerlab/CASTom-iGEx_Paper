# add pheno description

library('data.table')
library('stringr')

#####################################################
# convert phenoDat to the correct format:
# 2 type of phenotype CAD_HARD and CAD_SOFT
# based onn  Schunkert annotation
#####################################################

ukbb_fold <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/'
cad_ukbb_fold <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/'
outFold <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/'
expl_var <- '/psycl/g/mpsziller/lucia/PHESANT/variable-info/outcome_info_final_round3_modLT.tsv'

covDat_file <- paste0(cad_ukbb_fold, 'covariateMatrix_latestW.txt')
covDat <- fread(covDat_file, data.table = F)
CAD_pheno_code <- read.csv(paste0(cad_ukbb_fold, 'CAD_phenotype_toextract.csv'), h=T, stringsAsFactors = F)

# load original phenotype data #
phenoDat <- fread(paste0(cad_ukbb_fold,'ukb_Key34217_filteredFinal_phenoCADrelated.tab'), h=T, stringsAsFactors = F, data.table = F)
phenoDat <- phenoDat[match(covDat$genoSample_ID, phenoDat$userId), ]
phenoDat_ICD <- fread(sprintf(paste0(ukbb_fold, 'ukb39002_filtered_britishWhiteUnrelated_pheno.tab')), data.table=F, sep = '\t')
phenoDat_ICD <- phenoDat_ICD[match(covDat$genoSample_ID, phenoDat_ICD$userId), ]

print('loaded matrices')

id_n <- sapply(as.character(phenoDat$userId), function(x) !is.na(as.numeric(strsplit(x, split = '')[[1]][1])))
new_samples <- as.character(phenoDat$userId)
if(any(id_n)){
  new_samples[id_n] <- sapply(new_samples[id_n], function(x) paste0('X', x))   
}
phenoDat$userId <- new_samples

id_n <- sapply(as.character(phenoDat_ICD$userId), function(x) !is.na(as.numeric(strsplit(x, split = '')[[1]][1])))
new_samples <- as.character(phenoDat_ICD$userId)
if(any(id_n)){
  new_samples[id_n] <- sapply(new_samples[id_n], function(x) paste0('X', x))   
}
phenoDat_ICD$userId <- new_samples

# combine tables:
phenoDat_tot <- cbind(phenoDat, phenoDat_ICD[, colnames(phenoDat_ICD) %in% setdiff(colnames(phenoDat_ICD), colnames(phenoDat))])

info <- fread(expl_var, data.table = F)

pheno_field <- unique(unname(sapply(colnames(phenoDat_tot), function(x) strsplit(x, split = '_')[[1]][1])))
pheno_field <- unname(sapply(pheno_field, function(x) strsplit(x, split = 'x')[[1]][2]))
pheno_field <- pheno_field[!is.na(pheno_field)]
info <- info[info$FieldID %in% pheno_field, ]

new_var <- unique(CAD_pheno_code$new_id)
new_data <- matrix(nrow = nrow(phenoDat_tot), ncol = length(new_var))
colnames(new_data) <- new_var
new_data <- as.data.frame(new_data)

for(i in 1:length(new_var)){
  
  print(new_var[i])
  
  tmp_id <- info[info$FieldID %in% CAD_pheno_code$UKBB_ID[CAD_pheno_code$new_id == new_var[i]], ]
  id <- sapply(tmp_id$FieldID, function(x) paste0('x', x, '_'))
  if(length(id)>1){
    keep <- sapply(id, function(x) grepl(x, colnames(phenoDat_tot)))
    keep <- rowSums(keep)>0
  }else{
    keep <- grepl(id, colnames(phenoDat_tot))
  }
  tmp <- phenoDat_tot[, keep, drop = F]
  
  if(new_var[i] %in% c('History_cancer')){
    tmp[, grepl('x40006_', colnames(tmp))] <- as.numeric(!is.na(tmp[, grepl('x40006_', colnames(tmp))]))
    tmp[is.na(tmp)] <- 0
    new_data[, i]  <- as.numeric(rowSums(tmp)>0)
  }
  if(new_var[i] %in% c('Age', 'Gender')){
    
    new_data[, i]  <- tmp[, grepl('_0_0',colnames(tmp))]
  }
  if(new_var[i] %in% c('BMI')){
    new_data[, i] <- rowMeans(tmp, na.rm = T)
  }
  if(new_var[i] %in% c('LVEF')){
    new_data[, i] <- tmp[, grepl('_2_0',colnames(tmp))]
  }
  if(new_var[i] %in% c('Age_angina','Age_heart_attack','Age_stroke', 'Age_death')){
    tmp[tmp<0] <- NA
    new_data[rowSums(!is.na(tmp))>0, i] <- apply(tmp[rowSums(!is.na(tmp))>0,], 1, function(x) min(x, na.rm = T))
  }
  if(new_var[i]%in% c('Medication_Insulin')){
    
    tmp[tmp<0] <- NA
    meaning <- CAD_pheno_code$Coding[CAD_pheno_code$new_id == new_var[i]]
    new_tmp <- lapply(meaning, function(y) apply(tmp, 2, function(x) grepl(y, x)))
    new_tmp <- Reduce('+', new_tmp)
    new_data[, i] <- as.numeric(rowSums(new_tmp)>0)
    
  }
  
  if(new_var[i]%in% c('Smoking')){
    tmp[tmp<0] <- NA
    meaning <- CAD_pheno_code$Coding[CAD_pheno_code$new_id == new_var[i]]
    id_field <- CAD_pheno_code$UKBB_ID[CAD_pheno_code$new_id == new_var[i]]
    new_tmp <- list()
    for(j in 1:length(meaning)){
      new_tmp[[j]] <- apply(tmp[, grepl(id_field[j], colnames(tmp))], 2, function(x) grepl(meaning[j], x))
      new_tmp[[j]] <- as.numeric(rowSums(new_tmp[[j]])>0)
    }
    new_tmp <- Reduce('+', new_tmp)
    new_data[, i] <- as.numeric(new_tmp>0)
  }
  
  if(!new_var[i] %in% c('History_cancer', 'Age', 'Gender','BMI', 'LVEF', 'Age_angina','Age_heart_attack','Age_stroke', 'Age_death', 'Medication_Insulin', 'Smoking')){
    meaning <- CAD_pheno_code$Coding[CAD_pheno_code$new_id == new_var[i]]
    new_tmp <- lapply(meaning, function(y) apply(tmp, 2, function(x) grepl(y, x)))
    new_tmp <- Reduce('+', new_tmp)
    new_data[, i] <- as.numeric(rowSums(new_tmp)>0)
  }
  
}

type_dat <- rep('CONTINUOUS', ncol(new_data))
type_dat[apply(new_data, 2, function(x) length(unique(x)) <= 2)] <- 'CAT_SINGLE_UNORDERED'
  
desc_data <- data.frame(pheno_id = colnames(new_data), FieldID = colnames(new_data),	Field  = rep(NA, ncol(new_data)),	Path  = rep(NA, ncol(new_data)),	
                        Strata= rep(NA, ncol(new_data)),	Sexed= rep(NA, ncol(new_data)), Coding = rep(NA, ncol(new_data)),	
                        Coding_meaning = rep(NA, ncol(new_data)),	original_type = type_dat,	transformed_type = type_dat, nsamples = apply(new_data, 2, function(x) sum(!is.na(x))),	
                        nsamples_T = rep(NA, ncol(new_data)),	nsamples_F = rep(NA, ncol(new_data)))
desc_data$nsamples_T[desc_data$transformed_type == 'CAT_SINGLE_UNORDERED'] <- apply(new_data[,desc_data$transformed_type == 'CAT_SINGLE_UNORDERED'], 2, function(x) sum(x == 1, na.rm = T))
desc_data$nsamples_F[desc_data$transformed_type == 'CAT_SINGLE_UNORDERED'] <- apply(new_data[,desc_data$transformed_type == 'CAT_SINGLE_UNORDERED'], 2, function(x) sum(x == 0, na.rm = T))

new_data <- cbind(data.frame(Individual_ID = phenoDat_tot$userId, stringsAsFactors = F), new_data)

# save (separate age and gender)
write.table(x = new_data[, colnames(new_data) %in% c('Individual_ID','Age', 'Gender')], file = sprintf('%s/phenoMatrix_CADpheno_nominalAG.txt', outFold), col.names = T, row.names = F, sep = '\t', quote = F)
write.table(x = new_data[, !colnames(new_data) %in% c('Age', 'Gender')], file = sprintf('%s/phenoMatrix_CADpheno_nominal.txt', outFold), col.names = T, row.names = F, sep = '\t', quote = F)

write.table(x = desc_data[desc_data$pheno_id %in% c('Age', 'Gender'), ], file = sprintf('%s/phenotypeDescription_manualProc_CADpheno_nominalAG.txt', outFold), col.names = T, row.names = F, sep = '\t', quote = F)
write.table(x = desc_data[!desc_data$pheno_id %in% c('Age', 'Gender'), ], file = sprintf('%s/phenotypeDescription_manualProc_CADpheno_nominal.txt', outFold), col.names = T, row.names = F, sep = '\t', quote = F)







