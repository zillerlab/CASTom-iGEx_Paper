# compute priors
# distinguish between cell type info:
# single: ERG, MRG, substantia_nigra, anterior_caudate, mid_frontal_lobe, angular_gyrus, cingulate_gyrus, hippocampus_middle, inferior_temporal_lobe, NE,                   
#         dNPCs, FinalIDR_FPC_neuronal_ATAC_R2_macs2, FinalIDR_FPC_neuronal_ATAC_R4_macs2
# aggregate:
#     - Brain_group_Epi: ERG, MRG, substantia_nigra, anterior_caudate, mid_frontal_lobe, angular_gyrus, cingulate_gyrus, hippocampus_middle, inferior_temporal_lobe, NE, dNPCs
#     - FPC_group_Epi: FinalIDR_FPC_neuronal_ATAC_R2_macs2, FinalIDR_FPC_neuronal_ATAC_R4_macs2

options(max.print=1000)
options(stringsAsFactors = F)
library(Matrix)
library(argparse)

parser <- ArgumentParser(description="compute prior for each chr")

parser$add_argument("--inputDir", type = "character", help = "path to dosage genotype data")
parser$add_argument("--chr", type = "integer", help =  "chromosome")
parser$add_argument("--VarInfo_file", type = "character", help = "file containing gwas info")

args <- parser$parse_args()
inputDir <- args$inputDir
chr <- args$chr
VarInfo_file <- args$VarInfo_file


###########################
# chr <- 1
# VarInfo_file <-  '/ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA/Genotyping_data/Genotype_VariantsInfo_CMC-PGC_'
# inputDir <- '/ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v1/'
###########################

setwd(inputDir)
curChrom <- paste0("chr",chr)

# load GWAS results 
gwas_var <- read.table(sprintf("%s%s.txt", VarInfo_file, curChrom),sep="\t",header=T)

#create priors
priorMat <- as.data.frame(matrix(0,nrow(gwas_var),19))
colnames(priorMat) <- c('PGC_gwas', 'ERG_Epi', 'MRG_Epi', 'SubstantiaNigra_Epi', 'AnteriorCaudate_Epi', 'MidFrontalLobe_Epi', 'AngularGyrus_Epi','CingulateGyrus_Epi', 
                        'HippocampusMiddle_Epi',  'InferiorTemporalLobe_Epi', 'NE_Epi', 'dNPCs_Epi', 'FPC_Neuronal_ATAC_R2_Epi', 'FPC_Neuronal_ATAC_R4_Epi', 'Ctrl_150_allPeaks_cellRanger',
                        'Brain_group_Epi', 'FPC_group_Epi', 'PGC_gwas_bin', 'PGC_gwas_bin_v2')

# transform gwas p-values
w <- 1/(-1*log10(gwas_var$PVAL)) # 0.1 for p=10^-10
w[gwas_var$PVAL>=0.05] <- 1 # put to 1 when p>0.05
w[!is.finite(w)] <- 1 # correspond to p-value = 1
priorMat$PGC_gwas <- 1-w
  
priorMat$PGC_gwas_bin[gwas_var$PVAL <= 10^-2] <- 1
priorMat$PGC_gwas_bin_v2[gwas_var$PVAL <= 10^-5] <- 1
  
# use epistate to create prior, if the snp belong to at least 1 ct in a group, annotate as 0.1
epiAn <- read.table(gzfile(sprintf("hg19_SNPs-Epi_chr%i_matched.txt.gz", chr)),sep="\t",header=T)

### single CT ### 
ind <- which(epiAn$ERG!=0)
priorMat$ERG_Epi[ind] <- 1
  
ind <- which(epiAn$MRG!=0)
priorMat$MRG_Epi[ind] <- 1
  
ind <- which(epiAn$substantia_nigra!=0)
priorMat$SubstantiaNigra_Epi[ind] <- 1
  
ind <- which(epiAn$anterior_caudate!=0)
priorMat$AnteriorCaudate_Epi[ind] <- 1

ind <- which(epiAn$mid_frontal_lobe!=0)
priorMat$MidFrontalLobe_Epi[ind] <- 1

ind <- which(epiAn$angular_gyrus!=0)
priorMat$AngularGyrus_Epi[ind] <- 1

ind <- which(epiAn$cingulate_gyrus!=0)
priorMat$CingulateGyrus_Epi[ind] <- 1
  
ind <- which(epiAn$hippocampus_middle!=0)
priorMat$HippocampusMiddle_Epi[ind] <- 1

ind <- which(epiAn$inferior_temporal_lobe!=0)
priorMat$InferiorTemporalLobe_Epi[ind] <- 1

ind <- which(epiAn$NE!=0)
priorMat$NE_Epi[ind] <- 1

ind <- which(epiAn$dNPCs!=0)
priorMat$dNPCs_Epi[ind] <- 1

ind <- which(epiAn$FPC_neuronal_ATAC_R2!=0)
priorMat$FPC_Neuronal_ATAC_R2_Epi[ind] <- 1

ind <- which(epiAn$FPC_neuronal_ATAC_R4!=0)
priorMat$FPC_Neuronal_ATAC_R4_Epi[ind] <- 1

ind <- which(epiAn$Ctrl_150_allPeaks_cellRanger!=0)
priorMat$Ctrl_150_allPeaks_cellRanger[ind] <- 1


### group CT ###
selCT <- which(colnames(epiAn) %in% c('ERG', 'MRG', 'substantia_nigra', 'anterior_caudate', 
                                      'mid_frontal_lobe','angular_gyrus', 'cingulate_gyrus', 'hippocampus_middle', 'inferior_temporal_lobe', 'NE', 'dNPCs'))
ind <- which(rowSums(epiAn[,selCT]!=0)>0)
priorMat$Brain_group_Epi[ind] <- 1
  
selCT <- which(colnames(epiAn) %in% c('FPC_neuronal_ATAC_R2', 'FPC_neuronal_ATAC_R4'))
ind <- which(rowSums(epiAn[,selCT]!=0)>0)
priorMat$FPC_group_Epi[ind] <- 1
  
################################################################################################
# save
write.table(priorMat,paste0('priorMatrix_',curChrom,'.txt'),sep="\t",row.names=F,quote=F)
system(paste("gzip",paste0('priorMatrix_',curChrom,'.txt')))


