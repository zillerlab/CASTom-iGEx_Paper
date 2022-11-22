library('data.table')
library('stringr')

#####################################################
# convert phenoDat to the correct format:
# 2 type of phenotype CAD_HARD and CAD_SOFT
# based onn  Schunkert annotation
#####################################################

setwd('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/')
outFold <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/'
expl_var <- '/psycl/g/mpsukb/PHESANT/variable-info/outcome_info_final_round3_modLT.tsv'

covDat_file <- c('covariatesMatrix.txt')
covDat <- fread(covDat_file, data.table = F)
CAD_pheno_code_file <- paste0(outFold, c('phenotype_UKBB_CAD_Schunkert_HARD.csv', 'phenotype_UKBB_CAD_Schunkert_SOFT.csv'))

####### self reported already processed, create file #######
phenoDat_file <- 'phenotypeMatrix.txt'
phenoInfo_file <- 'phenotypeDescription_PHESANTproc.txt'

phenoDat <- fread(phenoDat_file, data.table = F)
phenoInfo <- fread(phenoInfo_file, data.table = F)
CAD_pheno_code <- lapply(CAD_pheno_code_file, function(x)  fread(x, data.table = F, h=F))
CAD_pheno_code[[2]] <- CAD_pheno_code[[2]][!CAD_pheno_code[[2]]$V1 %in% CAD_pheno_code[[1]]$V1,]

### disease self reported ###
tmp <- phenoInfo[phenoInfo$Field %in% 'Non-cancer illness code, self-reported',]
code_id <- sapply(tmp$pheno_id, function(x) strsplit(x, split = '_')[[1]][2])
code_id_CAD <- lapply(CAD_pheno_code, function(x) x$V1[x$V2 %in% 'Non-cancer illness code, self-reported'])
code_id_CAD <- lapply(code_id_CAD, function(x) paste(unique(tmp$FieldID), x, sep = '_'))
phenoDat_sfd <- lapply(code_id_CAD, function(x) as.data.frame(phenoDat[,colnames(phenoDat) %in% c('Individual_ID',x)], stringsAsFactor = F))

### operations self reported ###
tmp <- phenoInfo[phenoInfo$Field %in% 'Operation code',]
code_id <- sapply(tmp$pheno_id, function(x) strsplit(x, split = '_')[[1]][2])
code_id_CAD <- lapply(CAD_pheno_code, function(x) x$V1[x$V2 %in% 'Operation code'])
code_id_CAD <- lapply(code_id_CAD, function(x) paste(unique(tmp$FieldID), x, sep = '_'))
phenoDat_sfo <- lapply(code_id_CAD, function(x) as.data.frame(phenoDat[,colnames(phenoDat) %in% c('Individual_ID',x)], stringsAsFactor = F))

######## ICD9 ICD10 and OPSC4 original data (do not truncate code) ########
phenoDat <- fread(sprintf('ukb39002_filtered_britishWhiteUnrelated_pheno.tab'), data.table=F, sep = '\t')
phenoDat <- phenoDat[phenoDat$userId %in% covDat$genoSample_ID, ]
id_n <- sapply(as.character(phenoDat$userId), function(x) !is.na(as.numeric(strsplit(x, split = '')[[1]][1])))
new_samples <- as.character(phenoDat$userId)
if(any(id_n)){
  new_samples[id_n] <- sapply(new_samples[id_n], function(x) paste0('X', x))   
}
phenoDat$userId <- new_samples

info <- fread(expl_var, data.table = F)

pheno_field <- unique(unname(sapply(colnames(phenoDat), function(x) strsplit(x, split = '_')[[1]][1])))
pheno_field <- unname(sapply(pheno_field, function(x) strsplit(x, split = 'x')[[1]][2]))
pheno_field <- pheno_field[!is.na(pheno_field)]
info <- info[info$FieldID %in% pheno_field, ]

#### ICD9 ####
pheno_id <- info$FieldID[info$Field == 'Diagnoses - ICD9']
tmp <- phenoDat[, sapply(colnames(phenoDat), function(x) grepl(pheno_id, x))]
code_id_CAD <- lapply(CAD_pheno_code, function(x) x$V1[x$V2 %in% 'ICD9'])
phenoDat_ICD9 <- vector(mode = 'list', length = length(code_id_CAD))

for(j in 1:length(code_id_CAD)){
  phenoDat_ICD9[[j]] <-  data.frame(Individual_ID = phenoDat$userId, stringsAsFactors = F)
  for(i in 1:length(code_id_CAD[[j]])){
    print(i)
    new_name <- paste(pheno_id, code_id_CAD[[j]][i], sep = '_')
    phenoDat_ICD9[[j]] <- cbind(phenoDat_ICD9[[j]], rep(0, nrow(phenoDat_ICD9[[j]])))
    colnames(phenoDat_ICD9[[j]])[ncol(phenoDat_ICD9[[j]])] <- new_name
    id <- apply(apply(tmp, 2, function(x) x %in% code_id_CAD[[j]][i]), 1, any)
    phenoDat_ICD9[[j]][id, ncol(phenoDat_ICD9[[j]])] <- 1
  }
}

#### ICD10 ####
pheno_id <- info$FieldID[info$Field == 'Diagnoses - ICD10']
tmp <- phenoDat[, sapply(colnames(phenoDat), function(x) grepl(pheno_id, x))]
code_id_CAD <- lapply(CAD_pheno_code, function(x) x$V1[x$V2 %in% 'ICD10'])
phenoDat_ICD10 <- vector(mode = 'list', length = length(code_id_CAD))

for(j in 1:length(code_id_CAD)){
  phenoDat_ICD10[[j]] <-  data.frame(Individual_ID = phenoDat$userId, stringsAsFactors = F)
  for(i in 1:length(code_id_CAD[[j]])){
    print(i)
    new_name <- paste(pheno_id, code_id_CAD[[j]][i], sep = '_')
    phenoDat_ICD10[[j]] <- cbind(phenoDat_ICD10[[j]], rep(0, nrow(phenoDat_ICD10[[j]])))
    colnames(phenoDat_ICD10[[j]])[ncol(phenoDat_ICD10[[j]])] <- new_name
    id <- apply(apply(tmp, 2, function(x) x %in% code_id_CAD[[j]][i]), 1, any)
    phenoDat_ICD10[[j]][id, ncol(phenoDat_ICD10[[j]])] <- 1
  }
}

#### OPSC4 ####
pheno_id <- info$FieldID[info$Field == 'Operative procedures - OPCS4']
tmp <- phenoDat[, sapply(colnames(phenoDat), function(x) grepl(pheno_id, x))]
code_id_CAD <- lapply(CAD_pheno_code, function(x) x$V1[x$V2 %in% 'OPCS-4'])
phenoDat_OPSC4 <- vector(mode = 'list', length = length(code_id_CAD))

for(j in 1:length(code_id_CAD)){
  phenoDat_OPSC4[[j]] <-  data.frame(Individual_ID = phenoDat$userId, stringsAsFactors = F)
  if(length(code_id_CAD[[j]])>0){
    for(i in 1:length(code_id_CAD[[j]])){
      print(i)
      new_name <- paste(pheno_id, code_id_CAD[[j]][i], sep = '_')
      phenoDat_OPSC4[[j]] <- cbind(phenoDat_OPSC4[[j]], rep(0, nrow(phenoDat_OPSC4[[j]])))
      colnames(phenoDat_OPSC4[[j]])[ncol(phenoDat_OPSC4[[j]])] <- new_name
      id <- apply(apply(tmp, 2, function(x) x %in% code_id_CAD[[j]][i]), 1, any)
      phenoDat_OPSC4[[j]][id, ncol(phenoDat_OPSC4[[j]])] <- 1
    }
  }
}

##### conbine final results #####
pheno_final <- vector(mode = 'list', length = length(CAD_pheno_code))
common_samples <- intersect(phenoDat_sfd[[1]]$Individual_ID, phenoDat$userId)

id <- match(common_samples, phenoDat_sfd[[1]]$Individual_ID)
phenoDat_sfd <- lapply(phenoDat_sfd, function(x) x[id,])
phenoDat_sfo <- lapply(phenoDat_sfo, function(x) x[id,])

id <- match(common_samples, phenoDat$userId)
phenoDat_ICD9 <- lapply(phenoDat_ICD9, function(x) x[id,])
phenoDat_ICD10 <- lapply(phenoDat_ICD10, function(x) x[id,])
phenoDat_OPSC4 <- lapply(phenoDat_OPSC4, function(x) x[id,])

pheno_final[[1]] <- cbind(phenoDat_sfd[[1]], phenoDat_sfo[[1]][, -1], phenoDat_ICD9[[1]][, -1],  phenoDat_ICD10[[1]][, -1], phenoDat_OPSC4[[1]][, -1])
pheno_final[[2]] <- cbind(phenoDat_sfd[[2]], phenoDat_ICD9[[2]][, -1],  phenoDat_ICD10[[2]][, -1])

#####
phenoMat <- data.frame(Individual_ID = pheno_final[[1]]$Individual_ID, CAD_HARD = 0, CAD_SOFT = 0, stringsAsFactors = F)
phenoMat$CAD_HARD[rowSums(pheno_final[[1]][, -1])>0] <- 1
phenoMat$CAD_SOFT[rowSums(pheno_final[[1]][, -1])>0 | rowSums(pheno_final[[2]][, -1])>0] <- 1
covMat <- covDat[covDat$Individual_ID %in% phenoMat$Individual_ID, !colnames(covDat) %in% c('Array', 'Age', paste0('PC',11:20)), ]
covMat <- covMat[match(phenoMat$Individual_ID, covMat$Individual_ID), ]
covMat$Dx <- phenoMat$CAD_SOFT

# save
write.table(x = phenoMat, file = sprintf('%s/phenoMatrix.txt', outFold), col.names = T, row.names = F, sep = '\t', quote = F)
write.table(x = covMat, file = sprintf('%s/covariateMatrix.txt', outFold), col.names = T, row.names = F, sep = '\t', quote = F)

         
                       
                       

