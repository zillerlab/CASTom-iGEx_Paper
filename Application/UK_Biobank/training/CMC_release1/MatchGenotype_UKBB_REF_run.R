# mathc UKBB and CMC or GTEx data

options(max.print=1000)
options(stringsAsFactors = F)
library(Matrix)
library(argparse)

parser <- ArgumentParser(description="combind UKBB and CMC genotype (already matched with PGC)")

parser$add_argument("--inputUKBB", type = "character", help = "input folders UKBB annotation")
parser$add_argument("--outputUKBB", type = "character", help = "output folder UKBB annotation")
parser$add_argument("--inputREF", type = "character", help = "input folder GTEx or CMC annotation")
parser$add_argument("--outputREF", type = "character", help = "output folder GTEx or CMC annotation")
parser$add_argument("--REF_name", type = "character", help = "CMC or GTEx")
parser$add_argument("--freq_pop", type = "double", default = 0.15, help = "max different frequency in the populations, default coming from GTEx")
parser$add_argument("--curChrom", type = "character", help = "chromosome considered")

args <- parser$parse_args()
inputUKBB <- args$inputUKBB
outputUKBB <- args$outputUKBB
inputREF <- args$inputREF
outputREF <- args$outputREF
REF_name <- args$REF_name
freq_pop <- args$freq_pop
curChrom <- args$curChrom

#########################################################################
# inputUKBB <- '/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/correct_REF_ALT/'
# outputUKBB <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA_CMC/UKBB/Genotyping_data/'
# inputREF <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA_CMC/CMC/Genotyping_data/Genotype_VariantsInfo_CMC-PGC_'
# outputREF <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA_CMC/CMC/Genotyping_data/Genotype_VariantsInfo_CMC-PGCgwas-UKBB_'
# REF_name <- 'CMC'
# freq_pop <- 0.15
# curChrom <- 'chr22'
#########################################################################

info_var_REF <- read.table(sprintf('%s%s.txt', inputREF, curChrom), header = T, stringsAsFactors = F)
info_var_UKBB <-read.table(sprintf('%s%s_correct_altFreq.txt', inputUKBB, curChrom), header = F, stringsAsFactors = F, sep = ' ')

# remove duplicate positions from REF
id_dup <- names(which(table(info_var_REF$POS)>1))
if(length(id_dup)>0){
  info_var_REF <- info_var_REF[!(info_var_REF$POS %in% id_dup), ]  
}

# match base on position
common_pos <- c(info_var_UKBB[,4], info_var_REF$POS)
common_pos <- as.numeric(names(which(table(common_pos)==2)))
info_var_UKBB <- info_var_UKBB[info_var_UKBB$V4 %in% common_pos, ]
info_var_REF <- info_var_REF[info_var_REF$POS %in% common_pos, ]

print(paste('same length:', nrow(info_var_UKBB) == nrow(info_var_REF)))

common_dataset_POS <- cbind(info_var_REF$POS, info_var_UKBB$V4)
print(paste('same POS:', all(apply(common_dataset_POS, 1, function(x) length(unique(x))==1))))

common_dataset_REF <- cbind(info_var_REF$REF, info_var_UKBB$V5)
ref_eq <- all(apply(common_dataset_REF,1, function(x) length(unique(x))==1))
print(paste('same REF:', ref_eq)) # can be differente due to presence of indels
if(!ref_eq){
  id <- apply(common_dataset_REF, 1, function(x) length(unique(x))==1)
  info_var_REF <- info_var_REF[id, ]
  info_var_UKBB <- info_var_UKBB[id, ]
}

common_dataset_ALT <- cbind(info_var_REF$ALT, info_var_UKBB$V6)
alt_eq <- all(apply(common_dataset_ALT,1, function(x) length(unique(x))==1))
print(paste('same ALT:', alt_eq)) # can be different, multiallelic position

if(!alt_eq){
  id <- apply(common_dataset_ALT,1, function(x) length(unique(x))==1)
  info_var_REF <- info_var_REF[id, ]
  info_var_UKBB <- info_var_UKBB[id, ]
}

if(REF_name == 'CMC'){tmp <- info_var_REF$ALT_freq
}else{tmp <- info_var_REF$EXP_FREQ_A1_GTEx}

common_dataset_ALTfreq <- cbind(tmp,  info_var_UKBB$V7)
# filter out SNPs with different ALT_freq (european population)
id_freq <- abs(common_dataset_ALTfreq[,1]-common_dataset_ALTfreq[,2])<=freq_pop
info_var_REF <- info_var_REF[id_freq, ]
info_var_UKBB <- info_var_UKBB[id_freq, ]
print(paste('n. var removed for ALT freq:', length(which(!id_freq))))

# save, combine table all together
tot_var <- cbind(info_var_REF[, colnames(info_var_REF) %in% c('CHR', 'POS', 'ID', 'ID_PGC', 'ID_CAD')], info_var_UKBB[, c('V2', 'V3')], 
                 info_var_REF[, colnames(info_var_REF) %in% c('REF','ALT','PGC_A1','PGC_A2','CAD_EffAll','CAD_nonEffAll', 'ALT_freq', 'EXP_FREQ_A1_GTEx')], 
                 info_var_UKBB[, 'V7'], info_var_REF[, colnames(info_var_REF)  %in% c('PGC_OR','PGC_SE','PGC_PVAL', 'CAD_beta', 'CAD_se_dgc', 'CAD_p_dgc')])

colnames(tot_var)[colnames(tot_var) %in% c('V2', 'V3', 'info_var_UKBB[, "V7"]')] <- c('ID_UKBB', 'rsID_UKBB', 'ALT_freq_UKBB')

write.table(x = tot_var, file = sprintf('%s%s.txt', outputREF, curChrom), quote = F, col.names = T, row.names = F, sep = '\t')

# save only UKBB
colnames(info_var_UKBB) <- c('CHR', 'ID', 'rsID', 'POS', 'REF', 'ALT', 'ALTfrq')
write.table(x = info_var_UKBB, file = sprintf('%s/Genotype_VariantsInfo_matched%s_%s.txt', outputUKBB, REF_name, curChrom), quote = F, col.names = T, row.names = F, sep = '\t')
  


