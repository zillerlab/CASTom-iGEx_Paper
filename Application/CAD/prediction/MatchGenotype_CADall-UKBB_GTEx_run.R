# mathc all CAD cohorts + UKBB and GTEx data

options(max.print=1000)
options(stringsAsFactors = F)
library(Matrix)
library(argparse)

parser <- ArgumentParser(description="combind CAD-UKBB and GTEx genotype (already matched with PGC-CAD)")

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

#########################################################################
# inputPred <- c('/psycl/g/mpsukb/CAD/hrc_imputation/German1/oxford/ReplaceDots/correct_REF_ALT/', '/psycl/g/mpsukb/CAD/hrc_imputation/German2/oxford/ReplaceDots/correct_REF_ALT/',
#               '/psycl/g/mpsukb/CAD/hrc_imputation/German3/oxford/ReplaceDots/correct_REF_ALT/', '/psycl/g/mpsukb/CAD/hrc_imputation/German4/oxford/ReplaceDots/correct_REF_ALT/',
#               '/psycl/g/mpsukb/CAD/hrc_imputation/German5/oxford/ReplaceDots/correct_REF_ALT/', '/psycl/g/mpsukb/CAD/hrc_imputation/CG/oxford/ReplaceDots/correct_REF_ALT/', 
#               '/psycl/g/mpsukb/CAD/hrc_imputation/LURIC/oxford/ReplaceDots/correct_REF_ALT/', '/psycl/g/mpsukb/CAD/hrc_imputation/MG/oxford/ReplaceDots/correct_REF_ALT/',
#               '/psycl/g/mpsukb/CAD/hrc_imputation/WTCCC/oxford/ReplaceDots/correct_REF_ALT/', '/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/correct_REF_ALT/')
# namesPred <- c('G1', 'G2',  'G3',  'G4', 'G5', 'CG', 'LU', 'MG', 'WTC', 'UKBB')
# outputPred <- paste0('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/', c(paste0('German', 1:5), 'Cardiogenics', 'LURIC', 'MIGen', 'WTCCC', 'UKBB'))
# inputTrain <- '/psycl/g/mpsziller/lucia/CAD/eQTL_PROJECT/INPUT_DATA_GTEx/GTEX_v6/Genotyping_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas_'
# outputTrain <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/GTEX_v6/Genotyping_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-CADall-UKBB_'
# freq_pop <- 0.15
# curChrom <- 'chr22'
#########################################################################

info_var_train <- read.table(sprintf('%s%s.txt', inputTrain, curChrom), header = T, stringsAsFactors = F)
info_var_pred <- lapply(inputPred, function(x) read.table(sprintf('%s%s_correct_altFreq.txt', x, curChrom), header = F, stringsAsFactors = F, sep = ' '))

# remove duplicate positions from GTEx
# remove duplicate positions from GTEx and indels (not present in german1-5)
id_dup <- names(which(table(info_var_train$POS)>1))
if(length(id_dup)>0){
  info_var_train <- info_var_train[!(info_var_train$POS %in% id_dup), ]
}
id_ind <- sapply(info_var_train$REF, nchar)>1 | sapply(info_var_train$ALT, nchar)>1
info_var_train <- info_var_train[!id_ind,]

# match base on position
common_pos <- c(do.call(rbind, info_var_pred)[,4], info_var_train$POS)
common_pos <- as.numeric(names(which(table(common_pos)==length(namesPred)+1)))
info_var_pred <- lapply(info_var_pred, function(x) x[x$V4 %in% common_pos, ])
info_var_train <- info_var_train[info_var_train$POS %in% common_pos, ]

print(paste('same length:', length(unique(c(nrow(info_var_train), sapply(info_var_pred, nrow)))) == 1))

common_dataset_POS <- cbind(info_var_train$POS, sapply(info_var_pred, function(x) x$V4))
print(paste('same POS:', all(apply(common_dataset_POS,1, function(x) length(unique(x))==1))))

common_dataset_REF <- cbind(info_var_train$REF, sapply(info_var_pred, function(x) x$V5))
print(paste('same REF:', all(apply(common_dataset_REF,1, function(x) length(unique(x))==1)))) # expected true, match to ref genome hg19

common_dataset_ALT <- cbind(info_var_train$ALT, sapply(info_var_pred, function(x) x$V6))
alt_eq <- all(apply(common_dataset_ALT,1, function(x) length(unique(x))==1))
print(paste('same ALT:', alt_eq)) # can be different, multiallelic position

if(!alt_eq){
  id <- apply(common_dataset_ALT,1, function(x) length(unique(x))==1)
  info_var_train <- info_var_train[id, ]
  info_var_pred <- lapply(info_var_pred, function(x) x[id, ])
}

common_dataset_ALTfreq <- cbind(info_var_train$EXP_FREQ_A1_GTEx, sapply(info_var_pred, function(x) x$V7))
# filter out SNPs with different ALT_freq (european population)
id_freq <- apply(common_dataset_ALTfreq, 1, function(x) all(as.vector(dist(x, method = 'manhattan'))<=freq_pop))
info_var_train <- info_var_train[id_freq, ]
info_var_pred <- lapply(info_var_pred, function(x) x[id_freq, ])
print(paste('n. var removed for ALT freq:', length(which(!id_freq))))

# save, combine table all together
tot_var <- cbind(info_var_train[, 1:5], sapply(info_var_pred, function(x) x$V2), info_var_train[, 6:12], sapply(info_var_pred, function(x) x$V7), info_var_train[, 13:18])
colnames(tot_var)[6:(length(namesPred)+5)] <- sapply(namesPred, function(x) paste0('ID_', x))
colnames(tot_var)[(5+length(namesPred)+8):(5+length(namesPred)+8+length(namesPred)-1)] <- sapply(namesPred, function(x) paste0('ALTfrq_', x))

write.table(x = tot_var, file = sprintf('%s%s.txt', outputTrain, curChrom), quote = F, col.names = T, row.names = F, sep = '\t')

# save singular
for(i in 1:length(info_var_pred)){
  
  colnames(info_var_pred[[i]]) <- c('CHR', 'ID', 'rsID', 'POS', 'REF', 'ALT', 'ALTfrq')
  write.table(x = info_var_pred[[i]], file = sprintf('%s/%s.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_%s.txt', outputPred[i], namesPred[i], curChrom), quote = F, col.names = T, row.names = F, sep = '\t')
  
}

