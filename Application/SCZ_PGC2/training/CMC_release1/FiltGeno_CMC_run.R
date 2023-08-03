options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))

parser <- ArgumentParser(description="filt genotype file CMC matched with UKBB")

parser$add_argument("--infoInput_file", type = "character", help = "path input file for genotype")
parser$add_argument("--infomatchInput_file", type = "character", help = "path input file for genotype (matched)")
parser$add_argument("--dosageInput_fold", type = "character", help = "original dosages to be filtered")
parser$add_argument("--curChrom", type = "character", help = "chromosome")
parser$add_argument("--outFold", type = "character", help = "output folder")

args <- parser$parse_args()
infoInput_file <- args$infoInput_file
infomatchInput_file <- args$infomatchInput_file
dosageInput_fold <- args$dosageInput_fold
curChrom <- args$curChrom
outFold <- args$outFold

#####################################################################
# infomatchInput_file <- '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA_matchCAD/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-G1to5_'
# infoInput_file <- '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_'
# dosageInput_fold <- '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Genotype_data/'
# curChrom <- 'chr22'
# outFold <- '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA_matchCAD/Genotype_data/'
#####################################################################

info_var_matched <- read.table(sprintf('%s%s.txt', infomatchInput_file, curChrom), header = T, stringsAsFactors = F)
info_var <- read.table(sprintf('%s%s.txt', infoInput_file, curChrom), header = T, stringsAsFactors = F)
genoDat <- read.table(gzfile(sprintf('%s%s_matrix.txt.gz', dosageInput_fold, curChrom)), header = T, stringsAsFactors = F, check.names = F)

id <- which(info_var$ID_CMC %in% info_var_matched$ID_CMC)
print(paste('length filt and match equal:', length(id) == nrow(info_var_matched)))

genoDat_filt <- genoDat[id, ]

write.table(x = genoDat_filt, file = sprintf('%s%s_matrix.txt', outFold, curChrom), col.names = T, row.names = F, sep = '\t', quote = F)
system(paste("gzip",sprintf('%s%s_matrix.txt', outFold, curChrom)))



