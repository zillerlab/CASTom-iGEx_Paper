library('data.table')
library('stringr')

#####################################################
# convert phenoDat to the correct format:
# 1 variable for each type, binary T or F
# 
# save total output and filtered per disease interest
#####################################################

setwd('/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/')
phenoID <- c('39002')
coding_showcase <- '/psycl/g/mpsukb/PHESANT/variable-info/Codings_Showcase.csv'
expl_var <- '/psycl/g/mpsukb/PHESANT/variable-info/outcome_info_final_round3_modLT.tsv'

info <- fread(expl_var, data.table = F)
coding_total <- fread(coding_showcase, data.table = F)

covMat <- read.table('covariatesMatrix.txt', h=T,stringsAsFactors = F)
phenofile <- fread(sprintf('ukb%s_filtered_britishWhiteUnrelated_pheno.tab', phenoID), data.table=F, sep = '\t')
phenoDat <- phenofile[phenofile$userId %in% covMat$genoSample_ID, ]

id_n <- sapply(as.character(phenoDat$userId), function(x) !is.na(as.numeric(strsplit(x, split = '')[[1]][1])))
new_samples <- as.character(phenoDat$userId)
if(any(id_n)){
  new_samples[id_n] <- sapply(new_samples[id_n], function(x) paste0('X', x))   
}
phenoDat$userId <- new_samples


pheno_field <- unique(unname(sapply(colnames(phenoDat), function(x) strsplit(x, split = '_')[[1]][1])))
pheno_field <- unname(sapply(pheno_field, function(x) strsplit(x, split = 'x')[[1]][2]))
pheno_field <- pheno_field[!is.na(pheno_field)]
info <- info[info$FieldID %in% pheno_field, ]

# find field related to dates and delete them 
date_field <- info$FieldID[sapply(info$Field, function(x) grepl('Date', x))]
# # remove ICD9
# ICD9_field <- info$FieldID[sapply(info$Field, function(x) grepl('ICD9', x))]
# pheno_field <- pheno_field[!pheno_field %in% c(date_field, ICD9_field)]
pheno_field <- pheno_field[!pheno_field %in% c(date_field)]
pheno_field <- pheno_field[!pheno_field %in% '41201'] # remove external causes field
info <- info[info$FieldID %in% pheno_field, ]


pheno_final <- data.frame(Individual_ID = phenoDat$userId, stringsAsFactors = F)
new_pheno <- vector(mode = 'list', length = length(pheno_field))
thr_exclude <- 50 # exclude pheno if present in less than 50 cases
# create annotation file
new_expl <- vector(mode = 'list', length = length(pheno_field))

for(i in 1:length(pheno_field)){
  
  id <- sapply(colnames(phenoDat), function(x) grepl(pheno_field[i], x))
  tmp <- phenoDat[,id]
  coding_pheno <- apply(tmp, 2, unique)
  coding_pheno <- unique(unlist(coding_pheno))
  coding_pheno <- as.character(coding_pheno[!is.na(coding_pheno)])
  # there could be some bad annotation with initial balnk spot, correct:
  id_c <- sapply(coding_pheno, function(x) length(strsplit(x, '[ ]')[[1]])==2)
  if(any(id_c)){
    coding_pheno[id_c] <- sapply(coding_pheno[id_c], function(x) strsplit(x, '[ ]')[[1]][2])
    coding_pheno <- unique(coding_pheno)
  }
  
  new_pheno[[i]] <- data.frame(Individual_ID = phenoDat$userId, stringsAsFactors = F)
  
  # truncate to the third character
  coding_pheno_trunc <- unname(unique(sapply(coding_pheno, function(x) substring(text=x, 0, 3))))
  # exclude codings not present in the coding showcase (abrreviation could be not in the set)
  values <- coding_total$Value[coding_total$Coding %in% info$Coding[info$FieldID %in% pheno_field[i]] & coding_total$Value %in% coding_pheno_trunc]
  coding_pheno_trunc <- coding_pheno_trunc[coding_pheno_trunc %in% values]
  
  new_names <- paste(pheno_field[i], coding_pheno_trunc, sep = '_')
  for(j in 1:length(coding_pheno_trunc)){
    
    print(j)
    new_var <- rep(0, nrow(new_pheno[[i]]))
    id <- apply(tmp, 1, function(x) any(grepl(coding_pheno_trunc[j], x)))
    new_var[id] <- 1
    new_pheno[[i]] <- cbind(new_pheno[[i]], new_var)
    colnames(new_pheno[[i]])[ncol(new_pheno[[i]])] <- new_names[j]
    
  }
  
  id_rm <- apply(new_pheno[[i]][, -1], 2, function(x) length(which(x[!is.na(x)]==1)) < thr_exclude)
  new_pheno[[i]] <- new_pheno[[i]][, c(T, !id_rm)]
  coding_pheno_trunc <- coding_pheno_trunc[!id_rm]
  
  # reorder alphabetical or numerical
  new_pheno[[i]] <- cbind(data.frame(Individual_ID = new_pheno[[i]]$Individual_ID, stringsAsFactors = F), new_pheno[[i]][, -1][, order(colnames(new_pheno[[i]])[-1])])
  
  new_expl[[i]] <- data.frame(pheno_id = colnames(new_pheno[[i]])[-1], stringsAsFactors = F) 
  new_expl[[i]]$FieldID <-  rep(info$FieldID[info$FieldID %in% pheno_field[i]], ncol(new_pheno[[i]])-1)
  new_expl[[i]]$Field <-  rep(info$Field[info$FieldID %in% pheno_field[i]], ncol(new_pheno[[i]])-1)
  new_expl[[i]]$Path <-  rep(info$Path[info$FieldID %in% pheno_field[i]], ncol(new_pheno[[i]])-1)
  new_expl[[i]]$Strata <-  rep(info$Strata[info$FieldID %in% pheno_field[i]], ncol(new_pheno[[i]])-1)
  new_expl[[i]]$Sexed <-'Unisex'
  new_expl[[i]]$Coding <-  rep(info$Coding[info$FieldID %in% pheno_field[i]], ncol(new_pheno[[i]])-1)
  new_expl[[i]]$Coding_meaning <- coding_total$Meaning[coding_total$Coding %in% info$Coding[info$FieldID %in% pheno_field[i]] & coding_total$Value %in% coding_pheno_trunc]
  new_expl[[i]]$original_type <- 'CAT_SINGLE'
  new_expl[[i]]$transformed_type <- 'CAT_SINGLE_UNORDERED'
  new_expl[[i]]$nsamples <- apply(new_pheno[[i]][,-1], 2, function(x) length(x[!is.na(x)]))
  new_expl[[i]]$nsamples <- apply(new_pheno[[i]][,-1], 2, function(x) length(x[!is.na(x)]))
  new_expl[[i]]$nsamples_T <- apply(new_pheno[[i]][,-1], 2, function(x) length(which(x[!is.na(x)]==1)))
  new_expl[[i]]$nsamples_F <- apply(new_pheno[[i]][,-1], 2, function(x) length(which(x[!is.na(x)]==0)))
  
  
}

final_expl <- do.call(rbind, new_expl)
pheno_final <- cbind(pheno_final, do.call(cbind, lapply(new_pheno, function(x) x[, -1])))

# save
write.table(pheno_final, file = 'phenotypeMatrix_ICD9-10_OPCS4.txt', col.names = T, row.names = F, sep = '\t', quote = F)
write.table(final_expl, file ='phenotypeDescription_manualproc_ICD9-10_OPCS4.txt', col.names = T, row.names = F, sep = '\t', quote = F)

