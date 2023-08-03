# mathc all SCZ-PGC cohorts and CMC data

options(max.print=1000)
options(stringsAsFactors = F)
library(Matrix)
library(argparse)
library(data.table)

parser <- ArgumentParser(description="combine SCZ-PGC and CMC genotype (already matched with PGC)")

parser$add_argument("--inputPred", type = "character",nargs = '*' ,help = "input folders CAD annotation")
parser$add_argument("--namesPred", type = "character",nargs = '*' ,help = "abbreviation for CAD cohorts")
parser$add_argument("--outputPred", type = "character", nargs = '*', help = "output folder CAD annotation")
parser$add_argument("--inputTrain", type = "character", help = "input folder GTEx annotation")
parser$add_argument("--outputTrain", type = "character", help = "output folder GTEx annotation")
parser$add_argument("--freq_pop", type = "double", default = 0.15, help = "max different frequency in the populations, default coming from GTEx")
parser$add_argument("--curChrom", type = "character", help = "chromosome considered")

args <- parser$parse_args()
inputPred <- args$inputPred
namesPred <- args$namesPred
outputPred <- args$outputPred
inputTrain <- args$inputTrain
outputTrain <- args$outputTrain
freq_pop <- args$freq_pop
curChrom <- args$curChrom

########################################################################
# setwd('/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC')
# namesPred <- read.table('INPUT_DATA_matchSCZ-PGC/SCZ-PGC/SCZ_cohort_names', h=F, stringsAsFactors = F)$V1
# inputPred <- paste0('INPUT_DATA_matchSCZ-PGC/SCZ-PGC/Genotype_data/', namesPred,'/dos_', namesPred, '-qc.chr22.out.dosage.filt_maf001_info06_misscount20.gz')
# outputPred <- paste0('INPUT_DATA_matchSCZ-PGC/SCZ-PGC/Genotype_data/', namesPred)
# inputTrain <- 'INPUT_DATA_SCRIPTS_v1/Genotyping_data/Genotype_VariantsInfo_CMC-PGC_chr22.txt'
# outputTrain <- 'INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-SCZ-PGCall_'
# freq_pop <- 0.15
# curChrom <- 'chr22'
########################################################################

# note: frequency refers to A1, modify when searching for corret ref/alt

info_var_train <- read.table(inputTrain, header = T, stringsAsFactors = F)
info_var_pred <- lapply(inputPred, function(x) read.table(gzfile(x), header = T, stringsAsFactors = F))

# remove duplicate positions from CMC
id_dup <- names(which(table(info_var_train$POS)>1))
if(length(id_dup)>0){
  info_var_train <- info_var_train[!(info_var_train$POS %in% id_dup), ]
}

# match base on position
common_pos <- c(do.call(rbind, info_var_pred)[,3], info_var_train$POS)
common_pos <- as.numeric(names(which(table(common_pos)==length(namesPred)+1)))
info_var_pred <- lapply(info_var_pred, function(x) x[x$POS %in% common_pos, ])
info_var_train <- info_var_train[info_var_train$POS %in% common_pos, ]

print(paste('same length:', length(unique(c(nrow(info_var_train), sapply(info_var_pred, nrow)))) == 1))

common_dataset_POS <- cbind(info_var_train$POS, sapply(info_var_pred, function(x) x$POS))
print(paste('same POS:', all(apply(common_dataset_POS,1, function(x) length(unique(x))==1))))

#############################################################################################
# divide per SNPs and indels
id_snps_train <- nchar(info_var_train$REF) == 1 & nchar(info_var_train$ALT) == 1
id_snps_pred <- sapply(info_var_pred, function(x) nchar(x$A1) == 1 & nchar(x$A2) == 1)
tmp <- cbind(id_snps_train, id_snps_pred)
id_snps <- apply(tmp, 1, all)
id_indels <- apply(tmp, 1, function(x) all(!x))
print(paste('same SNPs and INDELs position:', length(which(id_snps)) + length(which(id_indels)) == nrow(info_var_train)))

### SNPs ###
info_var_train_snps <- info_var_train[id_snps,]
info_var_pred_snps <- lapply(info_var_pred, function(x) x[id_snps,])

# check A1 and A2 have the same ref/alt in all the datasets
ref_alt_train <- info_var_train_snps[, c('REF', 'ALT')]
ref_alt_pred <- lapply(info_var_pred_snps, function(x) x[,c('A1', 'A2')])
id_rm <- rep(F, nrow(info_var_train_snps))
id_switch <- matrix(F, ncol = length(namesPred), nrow = nrow(info_var_train_snps))

for(i in 1:nrow(info_var_train_snps)){
  tmp <- cbind(t(ref_alt_train[i,]), sapply(ref_alt_pred, function(x) x[i,]))
  if(length(unique(unlist(tmp)))>2){
    id_rm[i] <- T
  }else{
    if(length(unique(tmp[1,]))>1 | length(unique(tmp[2,]))>1){
      
      id_switch[i, which(apply(tmp[, -1], 2, function(x) !identical(tmp[,1], x))) ] <- T
    }
  }
}

# modify all frequency so that they refer to A2 (ALT)
for(j in 1:length(namesPred)){
  info_var_pred_snps[[j]]$A2_frq <- 1-info_var_pred_snps[[j]]$A1_frq
}


id <- which(apply(id_switch, 1, any))
print(length(id))

if(length(id)>0){

  switch_cohort <- id_switch[id,]

  for(j in 1:ncol(switch_cohort)){
    if(any(switch_cohort[,j])){
      tmp <- data.frame(CHROM=info_var_pred_snps[[j]]$CHROM[id], ID=info_var_pred_snps[[j]]$ID[id], POS=info_var_pred_snps[[j]]$POS[id], A1=info_var_pred_snps[[j]]$A2[id],
                        A2=info_var_pred_snps[[j]]$A1[id], A1_frq = info_var_pred_snps[[j]]$A2_frq[id], INFO = info_var_pred_snps[[j]]$INFO[id], A2_frq = info_var_pred_snps[[j]]$A1_frq[id])
      tmp <- tmp[switch_cohort[,j],]
      info_var_pred_snps[[j]][id[switch_cohort[,j]],] <- tmp
    }
  }
}

if(any(id_rm)){
  info_var_train_snps <- info_var_train_snps[!id_rm,]
  info_var_pred_snps <- lapply(info_var_pred_snps, function(x) x[!id_rm,])
}

common_dataset_REF <- cbind(info_var_train_snps$REF, sapply(info_var_pred_snps, function(x) x$A1))
print(paste('same REF snps:', all(apply(common_dataset_REF,1, function(x) length(unique(x))==1)))) 
common_dataset_ALT <- cbind(info_var_train_snps$ALT, sapply(info_var_pred_snps, function(x) x$A2))
print(paste('same ALT snps:', all(apply(common_dataset_ALT,1, function(x) length(unique(x))==1)))) 

### Indels ###
info_var_train_indels <- info_var_train[id_indels,]
info_var_pred_indels <- lapply(info_var_pred, function(x) x[id_indels,])

# check A1 and A2 have the same ref/alt in all the datasets
ref_alt_train <- info_var_train_indels[, c('REF', 'ALT')]
ref_alt_pred <- lapply(info_var_pred_indels, function(x) x[,c('A1', 'A2')])
id_rm <- rep(F, nrow(info_var_train_indels))
id_switch <- matrix(F, ncol = length(namesPred), nrow = nrow(info_var_train_indels))

for(i in 1:nrow(info_var_train_indels)){
  tmp <- cbind(t(ref_alt_train[i,]), sapply(ref_alt_pred, function(x) x[i,]))
  cond_cohort <- length(unique(unlist(tmp[, -1])))>2
  if(cond_cohort){
    id_rm[i] <- T
  }else{
    len <- max(nchar(tmp[, 1]))
    len_pred <- as.numeric(sapply(tmp[,2], function(x) strsplit(x, split = 'I')[[1]][2]))
    len_pred <- len_pred[!is.na(len_pred)]
    if(len != len_pred){
      id_rm[i] <- T
    }else{
      len <- unname(nchar(tmp[, 1]))
      len_pred <- unname(apply(tmp[, -1],2,  function(y) as.integer(sapply(y, function(x) strsplit(x, split = 'I')[[1]][2]))))
      id <- which(apply(len_pred, 2, function(x) !identical(x[1],len[1])))
      if(length(id)>0){
        id_switch[i, id] <- T
      }
    }
  }
}

# modify all frequency so that they refer to ALT
for(j in 1:length(namesPred)){
  info_var_pred_indels[[j]]$A2_frq <- 1-info_var_pred_indels[[j]]$A1_frq
}

id <- which(apply(id_switch, 1, any))
print(length(id))

if(length(id)>0){
  
  switch_cohort <- id_switch[id,]
  
  for(j in 1:ncol(switch_cohort)){
    if(any(switch_cohort[,j])){
      tmp <- data.frame(CHROM=info_var_pred_indels[[j]]$CHROM[id], ID=info_var_pred_indels[[j]]$ID[id], POS=info_var_pred_indels[[j]]$POS[id], A1=info_var_pred_indels[[j]]$A2[id], 
                        A2=info_var_pred_indels[[j]]$A1[id], A1_frq = info_var_pred_indels[[j]]$A2_frq[id], INFO = info_var_pred_indels[[j]]$INFO[id], A2_frq = info_var_pred_indels[[j]]$A1_frq[id])
      tmp <- tmp[switch_cohort[,j],]
      info_var_pred_indels[[j]][id[switch_cohort[,j]],] <- tmp  
    }
  }
}

if(any(id_rm)){
  info_var_train_indels <- info_var_train_indels[!id_rm,]
  info_var_pred_indels <- lapply(info_var_pred_indels, function(x) x[!id_rm,])
}

print('corrected ref and alt for indels')

########
info_var_pred <- mapply(function(x, y) rbind(x, y), x = info_var_pred_snps, y = info_var_pred_indels, SIMPLIFY = F)
info_var_pred <- lapply(info_var_pred, function(x) x[order(x$POS), ])
info_var_train <- rbind(info_var_train_snps, info_var_train_indels)
info_var_train <- info_var_train[order(info_var_train$POS), ]

# filter based on ALT freq
common_dataset_ALTfreq <- cbind(info_var_train$ALT_freq, sapply(info_var_pred, function(x) x$A2_frq))
# filter out SNPs with different ALT_freq (european population)
id_freq <- apply(common_dataset_ALTfreq, 1, function(x) all(as.vector(dist(x, method = 'manhattan'))<=freq_pop))
info_var_train <- info_var_train[id_freq, ]
info_var_pred <- lapply(info_var_pred, function(x) x[id_freq, ])
print(paste('n. var removed for ALT freq:', length(which(!id_freq))))

# save, combine table all together
tot_var <- cbind(info_var_train[, 1:8], sapply(info_var_pred, function(x) x$ID), info_var_train[, 9:12], sapply(info_var_pred, function(x) x$A2_frq))
colnames(tot_var)[9:(length(namesPred)+8)] <- sapply(namesPred, function(x) paste0('ID_', x))
colnames(tot_var)[(8+length(namesPred)+5):(8+length(namesPred)+4+length(namesPred))] <- sapply(namesPred, function(x) paste0('ALTfrq_', x))

write.table(x = tot_var, file = sprintf('%s%s_updated.txt', outputTrain, curChrom), quote = F, col.names = T, row.names = F, sep = '\t')

# # save singular
# for(i in 1:length(info_var_pred)){
#   print(i)
#   info_var_pred[[i]] <- info_var_pred[[i]][, c('CHROM', 'ID','POS', 'A1', 'A2', 'A2_frq')]
#   colnames(info_var_pred[[i]]) <- c('CHROM', 'ID','POS', 'REF', 'ALT', 'ALT_frq')
#   write.table(x = info_var_pred[[i]], file = sprintf('%s/%s.Genotype_VariantsInfo_matchedSCZ-PGCall-CMC_%s.txt', outputPred[i], namesPred[i], curChrom), quote = F, col.names = T, row.names = F, sep = '\t')
# }

