# create an annotation file explaining each variable in the final output of PHESANT

output <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/phesant_custom_scan..tsv'
output_info <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/phesant_custom_scan..log'
expl_var <- '/psycl/g/mpsukb/PHESANT/variable-info/outcome_info_final_round3_modLT.tsv'
coding_showcase <- '/psycl/g/mpsukb/PHESANT/variable-info/Codings_Showcase.csv'
coding_ordinal_info <- '/psycl/g/mpsukb/PHESANT/variable-info/data-coding-ordinal-info_modLT.txt'

library('data.table')
dat <- fread(output, data.table = F)
no_col <- max(count.fields(output_info, sep = "|"))
dat_info <- read.table(output_info, sep="|",fill=TRUE, header = F, col.names=c(1:no_col), stringsAsFactors = F)
# modify dat_info, keep field ID
new_dat_info <- list()
for(i in 1:nrow(dat_info)){
  
  print(i)
  tmp <- dat_info[i,!(is.na(dat_info[i,]) | dat_info[i,] == ''),]
  if(length(tmp)>2){
    
    if(! (any(sapply(tmp, function(x) grepl('Excluded',x))) | any(sapply(tmp, function(x) grepl(' SKIP ',x))))){
      
      new_dat_info[[i]] <- data.frame(FieldID = strsplit(tmp$X1, split  = '_')[[1]][1], original_type = NA, new_type = NA, stringsAsFactors = F) 
      id_type <- data.frame(type = c('CONTINUOUS_MAIN', 'CONTINUOUS', 'INTEGER', 'CAT_SINGLE', 'CAT_MULTIPLE', 
                                     'CAT_MUL_BINARY_VAR', 'CAT_ORD', 'CAT_SINGLE_BINARY', 'CAT_SINGLE_UNORDERED', 'CAT_SINGLE_TO_CAT_MULTIPLE'), 
                            id = NA, stringsAsFactors = F)
      if(any(tmp == ' CONTINUOUS MAIN ')){id_type$id[1] <- which(tmp == ' CONTINUOUS MAIN ')}
      if(any(tmp == ' CONTINUOUS ')){id_type$id[2] <- which(tmp == ' CONTINUOUS ')}
      if(any(tmp == ' INTEGER ')){id_type$id[3] <- which(tmp == ' INTEGER ')}
      if(any(tmp == ' CAT-SINGLE ')){id_type$id[4] <- which(tmp == ' CAT-SINGLE ')}
      if(any(tmp == ' CAT-MULTIPLE ')){id_type$id[5] <- which(tmp == ' CAT-MULTIPLE ')}
      if(any(sapply(tmp, function(x) grepl('CAT-MUL-BINARY-VAR',x)))){id_type$id[6] <- which(sapply(tmp, function(x) grepl('CAT-MUL-BINARY-VAR',x)))[1]}
      if(any(tmp == ' CAT-ORD ')){id_type$id[7] <- which(tmp == ' CAT-ORD ')}
      if(any(tmp == ' CAT-SINGLE-BINARY ')){id_type$id[8] <- which(tmp == ' CAT-SINGLE-BINARY ')}
      if(any(tmp == ' CAT-SINGLE-UNORDERED ')){id_type$id[9] <- which(tmp == ' CAT-SINGLE-UNORDERED ')}
      if(any(tmp == ' cat-single to cat-multiple ')){id_type$id[10] <- which(tmp == ' cat-single to cat-multiple ')}
     
      
      new_dat_info[[i]]$original_type <- id_type$type[which.min(id_type$id)]
      new_dat_info[[i]]$new_type <- id_type$type[which.max(id_type$id)]
      
    }
  }
}

new_dat_info <- do.call(rbind, new_dat_info)

info <- fread(expl_var, data.table = F)
coding <- fread(coding_showcase, data.table = F)
expl_coding <- fread(coding_ordinal_info, data.table = F)

split_fieldID <- unname(sapply(colnames(dat), function(x) strsplit(x, split = '_')[[1]][1]))
total_fieldID <- unique(split_fieldID[-(1:3)])
info <- info[info$FieldID %in% total_fieldID,]

expl_dat <- data.frame(pheno_id = colnames(dat), FieldID = NA, Field=NA, Path = NA, Strata=NA, Sexed=NA, Coding=NA, Coding_meaning = NA, original_type = NA, 
                       transformed_type = NA, nsamples = NA, nsamples_T = NA, nsamples_F = NA, stringsAsFactors = F)
expl_dat$FieldID[2:3] <- c('21003', '31')
expl_dat$Field[2:3] <- c('Age', 'Sex')
expl_dat$nsamples[1:3] <- nrow(dat)

for(i in 1:length(total_fieldID)){
  
  # print(i)
  id <- which(split_fieldID %in% total_fieldID[i])
  
  if(length(id)==1){
    expl_dat[id,c('FieldID', 'Field', 'Path', 'Strata', 'Sexed', 'Coding')] <- info[info$FieldID == total_fieldID[i], c('FieldID', 'Field', 'Path', 'Strata', 'Sexed', 'Coding')]
    expl_dat[id,c('original_type', 'transformed_type')] <- new_dat_info[new_dat_info$FieldID %in% total_fieldID[i],2:3]  
    
    expl_dat$nsamples[id] <- sum(!is.na(dat[, id]))
    if(is.logical(dat[, id])){
      expl_dat$nsamples_T[id] <- sum(dat[, id], na.rm = T)
      expl_dat$nsamples_F[id] <- sum(!dat[, id], na.rm = T)
    }
    
  }else{
    
    expl_dat$nsamples[id] <- apply(dat[, id], 2, function(x) sum(!is.na(x)))
    expl_dat$nsamples_T[id] <- apply(dat[, id], 2, function(x) sum(x, na.rm = T))
    expl_dat$nsamples_F[id] <- apply(dat[, id], 2, function(x) sum(!x, na.rm = T))
    
    
    expl_dat[id,c('FieldID', 'Field', 'Path', 'Strata', 'Sexed', 'Coding')] <- matrix(rep(t(info[info$FieldID == total_fieldID[i], 
                                                                                       c('FieldID', 'Field', 'Path', 'Strata', 'Sexed', 'Coding')]), 
                                                                              length(id)), nrow = length(id), byrow = T)
    expl_dat[id,c('original_type', 'transformed_type')] <- matrix(rep(t(new_dat_info[new_dat_info$FieldID %in% total_fieldID[i],2:3]), 
                                                                                  length(id)), nrow = length(id), byrow = T)
    
    tmp_cod <- coding[coding$Coding %in% info[info$FieldID == total_fieldID[i],'Coding'],]
    tmp_expl_cod <- expl_coding[expl_coding$dataCode == info[info$FieldID == total_fieldID[i],'Coding'],]
    if(tmp_expl_cod$reassignments != ""){
      reassign = strsplit(tmp_expl_cod$reassignments, split = '[|]')[[1]]
      tmp <- sapply(reassign, function(x) strsplit(x, split = '=')[[1]]) 
      id_original <- tmp[1,]
      id_sub <- tmp[2,]
      for(j in 1:ncol(tmp)){
        print(i)
        tmp_cod$Value[tmp_cod$Value == id_original[j]] <- id_sub[j]  
      }
      
    }
    
    id_cod <- sapply(expl_dat$pheno_id[id], function(x) strsplit(x, split = '_')[[1]][2])
    tmp_cod <- tmp_cod[sapply(id_cod, function(x) which(x==tmp_cod$Value)),]
    expl_dat$Coding_meaning[id] <- tmp_cod$Meaning
    

  }
}

write.table(expl_dat, file = '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/phenotypeDescription_PHESANTproc.txt',col.names = T, row.names = F, sep = '\t', quote = F)


###
# produce final output of phenotype 
# 1) all phenotype that do not need covariate info other than age, sex, PC1-20, array
# 2) imaging data corrected for axis position + age, sex, PC1-20, array
# 3) numeric memory corrected for time and number of digits + age, sex, PC1-20, array
# 4) symbol digits substittution

covDat <- read.table('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariatesMatrix.txt', h=T, stringsAsFactors = F, sep = '\t')
# remove from covDat Array (all 1 array) and PC11-20
covDat <- covDat[, !colnames(covDat) %in% c('Array', paste0('PC', 11:20))]
# save
write.table(file = '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariatesMatrix_red.txt', x = covDat, col.names = T, row.names = F, sep = '\t', quote = F)


id_n <- sapply(as.character(dat$userId), function(x) !is.na(as.numeric(strsplit(x, split = '')[[1]][1])))
new_samples <- as.character(dat$userId)
if(any(id_n)){
  new_samples[id_n] <- sapply(new_samples[id_n], function(x) paste0('X', x))   
}

# create a list of the major category (from path), exclude some specific ones
path_list <- unique(expl_dat$Path)
path_list <- path_list[!is.na(path_list)]
tmp <- sapply(path_list, function(x) strsplit(x, ' > ')[[1]])
path_list <- sapply(tmp, function(x) x[length(x)])
path_list <- unname(unique(path_list))

exclude_path <- c('Early life factors', 'Employment', 'Baseline characteristics', 'Social support', 'Sun exposure', 
                  'Employment history', 'Residential air pollution', 'Residential noise pollution', 'Death register', 'Operations')
special_cov_path <- c('T1 structural brain MRI', 'Numeric memory', 'Symbol digit substitution', 'Medical conditions')

for(i in 1:length(path_list)){
  
  print(path_list[i])
  
  if(!path_list[i] %in% c(exclude_path, special_cov_path)){
    
    path_fieldID <- expl_dat[sapply(expl_dat$Path, function(x) grepl(path_list[i] ,x)),]
    pheno_tmp <- data.frame(Individual_ID = new_samples, dat[, as.character(path_fieldID$pheno_id)], check.names = F, stringsAsFactors = F)
    
    for(j in 1:ncol(pheno_tmp)){
      if(is.logical(pheno_tmp[,j])){
        # print(j)  
        pheno_tmp[,j] <- as.numeric(as.factor(pheno_tmp[,j]))-1
      }
    }
    name_group <- paste0(strsplit(path_list[i], split = ' ')[[1]], collapse = '_')
    # save
    write.table(x = pheno_tmp, file = sprintf('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/phenotypeMatrix_%s.txt', name_group), col.names = T, row.names = F, sep = '\t', quote = F)
    
  }
  
}

### consider a subset of Medical conditions ###
path_fieldID <- expl_dat[sapply(expl_dat$Path, function(x) grepl('Medical conditions' ,x)),]
path_fieldID <- path_fieldID[path_fieldID$Coding_meaning %in% c('depression', 'migraine', 'epilepsy', 'anxiety/panic attacks', 'schizophrenia', 
                                                                'nervous breakdown','headaches (not migraine)', 'stress', 'mania/bipolar disorder/manic depression', 
                                                                'anorexia/bulimia/other eating disorder', 'alcohol dependency', 'insomnia', 'deliberate self-harm/suicide attempt', 
                                                                'post-natal depression', 'post-traumatic stress disorder'), ]
pheno_tmp <- data.frame(Individual_ID = new_samples, dat[, as.character(path_fieldID$pheno_id)], check.names = F, stringsAsFactors = F)

for(j in 1:ncol(pheno_tmp)){
  if(is.logical(pheno_tmp[,j])){
    # print(j)  
    pheno_tmp[,j] <- as.numeric(as.factor(pheno_tmp[,j]))-1
  }
}
name_group <- 'Medical_conditions'
# save
write.table(x = pheno_tmp, file = sprintf('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/phenotypeMatrix_%s.txt', name_group), col.names = T, row.names = F, sep = '\t', quote = F)


### T1 structural brain MRI ###
imaging_fieldID <- expl_dat[sapply(expl_dat$Path, function(x) grepl('T1 structural brain MRI' ,x)),]
phenoMRI <- data.frame(Individual_ID = new_samples, dat[, imaging_fieldID$pheno_id], check.names = F)
covMRI <- merge(x = covDat, y = phenoMRI, sort = F, by.x = 'Individual_ID', by.y = 'Individual_ID')
id_cov_MRI <- c('25756', '25757', '25758', '25759')
covMRI <- covMRI[, c('Individual_ID', paste0('PC', 1:10), 'Gender', 'Age', id_cov_MRI )]
phenoMRI <- phenoMRI[, ! colnames(phenoMRI) %in% id_cov_MRI]
# convert TRUE/FALSE to 0-1
for(i in 1:ncol(phenoMRI)){
  
  if(is.logical(phenoMRI[,i])){
    print(i)  
    phenoMRI[,i] <- as.numeric(as.factor(phenoMRI[,i]))-1
  }
}
name_group <- 'T1_structural_brain_MRI'
# save
write.table(x = covMRI, file = sprintf('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariatesMatrix_%s.txt', name_group),col.names = T, row.names = F, sep = '\t', quote = F)
write.table(x = phenoMRI, file = sprintf('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/phenotypeMatrix_%s.txt', name_group),col.names = T, row.names = F, sep = '\t', quote = F)

### numeric memory (assessment centre) ###
numMemory_fieldID <- expl_dat[sapply(expl_dat$Path, function(x) grepl('UK Biobank Assessment Centre > Cognitive function > Numeric memory' ,x)),]
pheno_numMemory <- data.frame(Individual_ID = new_samples, dat[, numMemory_fieldID$pheno_id], check.names = F)
cov_numMemory <- merge(x = covDat, y = pheno_numMemory, sort = F, by.x = 'Individual_ID', by.y = 'Individual_ID')
id_cov_numMemory <- c('4250', '4253', '4283', '4285')
cov_numMemory <- cov_numMemory[, c('Individual_ID', paste0('PC', 1:10), 'Gender', 'Age', id_cov_numMemory )]
pheno_numMemory <- pheno_numMemory[, ! colnames(pheno_numMemory) %in% c(id_cov_numMemory, '4260')]
# convert TRUE/FALSE to 0-1
for(i in 1:ncol(pheno_numMemory)){
  
  if(is.logical(pheno_numMemory[,i])){
    print(i)  
    pheno_numMemory[,i] <- as.numeric(as.factor(pheno_numMemory[,i]))-1
  }
}
name_group <- 'Numeric_memory'
# save
write.table(x = cov_numMemory, file = sprintf('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariatesMatrix_%s.txt', name_group),col.names = T, row.names = F, sep = '\t', quote = F)
write.table(x = pheno_numMemory, file = sprintf('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/phenotypeMatrix_%s.txt', name_group),col.names = T, row.names = F, sep = '\t', quote = F)

### numeric memory (Online follow-up) ###
numMemory_fieldID <- expl_dat[sapply(expl_dat$Path, function(x) grepl('Online follow-up > Cognitive function online > Numeric memory' ,x)),]
pheno_numMemory <- data.frame(Individual_ID = new_samples, dat[, numMemory_fieldID$pheno_id], check.names = F)
# convert TRUE/FALSE to 0-1
for(i in 1:ncol(pheno_numMemory)){
  
  if(is.logical(pheno_numMemory[,i])){
    print(i)  
    pheno_numMemory[,i] <- as.numeric(as.factor(pheno_numMemory[,i]))-1
  }
}
colnames(pheno_numMemory) <- c('Individual_ID',numMemory_fieldID$pheno_id)
name_group <- 'Numeric_memory_online'
# save
write.table(x = pheno_numMemory, file = sprintf('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/phenotypeMatrix_%s.txt', name_group),col.names = T, row.names = F, sep = '\t', quote = F)


### Symbol digit substitution
symbolSub_fieldID <- expl_dat[sapply(expl_dat$Path, function(x) grepl('Symbol digit substitution' ,x)),]
pheno_symbolSub <- data.frame(Individual_ID = new_samples, dat[, symbolSub_fieldID$pheno_id], check.names = F)
cov_symbolSub <- merge(x = covDat, y = pheno_symbolSub, sort = F, by.x = 'Individual_ID', by.y = 'Individual_ID')
id_cov_symbolSub <- c('20195', '20200')
cov_symbolSub <- cov_symbolSub[, c('Individual_ID', paste0('PC', 1:10), 'Gender', 'Age', id_cov_symbolSub )]
pheno_symbolSub <- pheno_symbolSub[, ! colnames(pheno_symbolSub) %in% c(id_cov_symbolSub, '20229')]
# convert TRUE/FALSE to 0-1
for(i in 1:ncol(pheno_symbolSub)){
  
  if(is.logical(pheno_symbolSub[,i])){
    print(i)  
    pheno_symbolSub[,i] <- as.numeric(as.factor(pheno_symbolSub[,i]))-1
  }
}
# save
name_group <- 'Symbol_digit_substitution'
write.table(x = cov_symbolSub, file = sprintf('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariatesMatrix_%s.txt', name_group),col.names = T, row.names = F, sep = '\t', quote = F)
write.table(x = pheno_symbolSub, file = sprintf('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/phenotypeMatrix_%s.txt', name_group),col.names = T, row.names = F, sep = '\t', quote = F)




