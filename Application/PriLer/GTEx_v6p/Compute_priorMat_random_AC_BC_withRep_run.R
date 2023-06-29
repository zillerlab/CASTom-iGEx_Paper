# create prior from already compute Epi, random configuration with repetititon

options(max.print=1000)
options(stringsAsFactors = F)
library(Matrix)
library(argparse)

parser <- ArgumentParser(description="compute prior for each chr")

parser$add_argument("--EpiRandom_File", type = "character", help = "file to epi-snp annotation (randomly created)")
parser$add_argument("--Epi_File", type = "character", help = "file to epi-snp annotation")
parser$add_argument("--chr", type = "character", help =  "chromosome")
parser$add_argument("--GWAS_File", type = "character", help = "file containing gwas info")
parser$add_argument("--outputFile", type = "character", help = "output fold")

args <- parser$parse_args()
EpiRandom_File <- args$EpiRandom_File
Epi_File <- args$Epi_File
chr <- args$chr
GWAS_File <- args$GWAS_File
outputFile <- args$outputFile

########################################################################################
# EpiRandom_File <- '/mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/hg19_SNPs-Epi_randomSC_'
# Epi_File <- '/mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/hg19_SNPs-Epi_'
# GWAS_File <- '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Genotype_data/randomGWAS/randomGWAS_PVAL_PGC-CAD_'
# outputFile <- '/mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/priorMatrix_random_Ctrl_150_allPeaks_allRanger_heart_left_ventricle_GWAS_withRep_'
# chr <- 'chr22'
########################################################################################

gwas_info <- read.table(gzfile(sprintf("%s%s.txt.gz", GWAS_File, chr)),sep="\t",header=T)
epiAn <- read.table(gzfile(sprintf("%s%s_matched.txt.gz", Epi_File, chr)),sep="\t",header=T) 
epiAn_random <- read.table(gzfile(sprintf("%s%s_matched.txt.gz", EpiRandom_File, chr)),sep="\t",header=T)

# remove ID columns
id <- sapply(colnames(epiAn), function(x) strsplit(x, split = 'ID')[[1]][1] == '' | x %in% c('chrom', 'chromstart', 'chromend'))
epiAn <- epiAn[, !id]
# print(colnames(epiAn))
id <- sapply(colnames(gwas_info), function(x) strsplit(x, split = 'ID')[[1]][1] == '' | x %in% c('CHR', 'POS', 'REF', 'ALT'))
gwas_info <- gwas_info[, !id]
PGC_id <- sapply(colnames(gwas_info), function(x) length(strsplit(x, split = 'PGC')[[1]]))>1
CAD_id <- sapply(colnames(gwas_info), function(x) length(strsplit(x, split = 'CAD')[[1]]))>1

# create prior Mat
# epiMat binary, just attach the columns
priorMat <- cbind(epiAn,epiAn_random)

# transform gwas p-values (only binary)
w_PGC <- matrix(0, nrow = nrow(gwas_info), ncol = ncol(gwas_info[, PGC_id]))
w_CAD <- matrix(0, nrow = nrow(gwas_info), ncol = ncol(gwas_info[, CAD_id]))
w_PGC[gwas_info[, PGC_id] <= 10^-2] <- 1
w_CAD[gwas_info[, CAD_id] <= 5*10^-2] <- 1

colnames(w_PGC) <- colnames(gwas_info[, PGC_id])
colnames(w_CAD) <- colnames(gwas_info[, CAD_id])
w_PGC <- as.data.frame(w_PGC)
w_CAD <- as.data.frame(w_CAD)

priorMat <- cbind(priorMat, w_PGC, w_CAD)
colnames(priorMat)[colnames(priorMat) %in% c('PGC_PVAL', 'CAD_p_dgc')] <- c('PGC_gwas_bin', 'CAD_gwas_bin')

# save
write.table(priorMat, paste0(outputFile, chr,'.txt'),sep="\t",row.names=F,quote=F)
system(paste("gzip",paste0(outputFile, chr,'.txt')))


