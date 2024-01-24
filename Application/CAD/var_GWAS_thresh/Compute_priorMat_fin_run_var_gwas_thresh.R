# compute priors, put all cel lines

options(max.print=1000)
options(stringsAsFactors = F)
library(Matrix)
library(argparse)

parser <- ArgumentParser(description="compute prior for each chr")

parser$add_argument("--inputDir", type = "character", help = "path to epi-snp annotation")
parser$add_argument("--chr", type = "integer", help =  "chromosome")
parser$add_argument("--VarInfo_file", type = "character", help = "file containing gwas info")
parser$add_argument("--outputDir", type = "character", help = "output fold")

args <- parser$parse_args()
inputDir <- args$inputDir
chr <- args$chr
VarInfo_file <- args$VarInfo_file
outputDir <- args$outputDir

###########################
# chr <- 1
# VarInfo_file <-  '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_'
# inputDir <- '/mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT/'
# outputDir <- '/mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_new/'
###########################

setwd(inputDir)
curChrom <- paste0("chr",chr)

# load GWAS results 
gwas_var <- read.table(sprintf("%s%s.txt", VarInfo_file, curChrom),sep="\t",header=T)

# use epistate to create prior, if the snp belong to at least 1 ct in a group, annotate as 0.1
epiAn <- read.table(gzfile(sprintf("hg19_SNPs-Epi_chr%i_matched.txt.gz", chr)),sep="\t",header=T)
# remove ID columns
id <- sapply(colnames(epiAn), function(x) strsplit(x, split = 'ID')[[1]][1] == '' | x %in% c('chrom', 'chromstart', 'chromend'))
epiAn <- epiAn[, !id]
#print(colnames(epiAn))

#create priors
priorMat <- as.data.frame(matrix(0,nrow = nrow(gwas_var),ncol = ncol(epiAn)+16)) # D: Changed 6 to 16
colnames(priorMat) <- c('PGC_gwas', 'CAD_gwas', colnames(epiAn),'PGC_gwas_bin', 'CAD_gwas_bin', 'PGC_gwas_bin_v2', 'CAD_gwas_bin_v2',
                        "CAD_gwas_bin_p00001", "CAD_gwas_bin_p0001", "CAD_gwas_bin_p001", "CAD_gwas_bin_p005", "CAD_gwas_bin_p01",
                        "PGC_gwas_bin_p00001", "PGC_gwas_bin_p0001", "PGC_gwas_bin_p001", "PGC_gwas_bin_p005", "PGC_gwas_bin_p01")

                        
# transform gwas p-values
w <- 1/(-1*log10(gwas_var$PGC_PVAL)) # 0.1 for p=10^-10
w[gwas_var$PGC_PVAL>=0.05] <- 1 # put to 1 when p>0.05
w[!is.finite(w)] <- 1 # correspond to p-value = 1
priorMat$PGC_gwas <- 1-w
priorMat$PGC_gwas_bin_v2[gwas_var$PGC_PVAL <= 10^-5] <- 1
priorMat$PGC_gwas_bin[gwas_var$PGC_PVAL <= 10^-2] <- 1

# Recompute PGC GWAS prior based on different thresholds - Georgii
priorMat$PGC_gwas_bin_p00001[gwas_var$PGC_PVAL <= 0.0001] <- 1
priorMat$PGC_gwas_bin_p0001[gwas_var$PGC_PVAL <= 0.001] <- 1
priorMat$PGC_gwas_bin_p001[gwas_var$PGC_PVAL <= 0.01] <- 1
priorMat$PGC_gwas_bin_p005[gwas_var$PGC_PVAL <= 0.05] <- 1
priorMat$PGC_gwas_bin_p01[gwas_var$PGC_PVAL <= 0.1] <- 1

w <- 1/(-1*log10(gwas_var$CAD_p_dgc)) # 0.1 for p=10^-10
w[gwas_var$CAD_p_dgc>=0.05] <- 1 # put to 1 when p>0.05
w[!is.finite(w)] <- 1 # correspond to p-value = 1
priorMat$CAD_gwas <- 1-w
priorMat$CAD_gwas_bin[gwas_var$CAD_p_dgc <= 0.05] <- 1 # comparable distribution  CAD-PGC for this threshold
priorMat$CAD_gwas_bin_v2[gwas_var$CAD_p_dgc <= 10^-3] <- 1

# Recompute CAD GWAS prior based on different thresholds - Georgii
priorMat$CAD_gwas_bin_p00001[gwas_var$CAD_p_dgc <= 0.0001] <- 1
priorMat$CAD_gwas_bin_p0001[gwas_var$CAD_p_dgc <= 0.001] <- 1
priorMat$CAD_gwas_bin_p001[gwas_var$CAD_p_dgc <= 0.01] <- 1
priorMat$CAD_gwas_bin_p005[gwas_var$CAD_p_dgc <= 0.05] <- 1
priorMat$CAD_gwas_bin_p01[gwas_var$CAD_p_dgc <= 0.1] <- 1

### single CT ### 
for(ct in colnames(epiAn)){
  
  #print(ct)
  id_ct <- which(colnames(priorMat)==ct)
  ind <- which(epiAn[, colnames(epiAn) == ct]!=0)
  priorMat[ind, id_ct] <- 1
  
}


################################################################################################
# save
write.table(priorMat,paste0(outputDir, 'priorMatrix_',curChrom,'.txt'),sep="\t",row.names=F,quote=F)
system(paste("gzip", "-f", paste0(outputDir, 'priorMatrix_',curChrom,'.txt')))

print(sprintf("Chr %s done", chr))
