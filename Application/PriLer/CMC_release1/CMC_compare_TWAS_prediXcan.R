# CMC on slurmgate:
options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(Matrix))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(gridExtra))
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(circlize))
suppressPackageStartupMessages(library(ggsci))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(latex2exp))

# add on TWAs results number of snps for each model
twas_fold <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/TWAS/'
twas_modelInfo <- read.table(paste0(twas_fold, 'CMC.BRAIN.RNASEQ.profile'), header = T, stringsAsFactors = F)
twas_modelInfo <- cbind(twas_modelInfo, data.frame(top1.nsnps = rep(NA, nrow(twas_modelInfo)),blup.nsnps = rep(NA, nrow(twas_modelInfo)),enet.nsnps = rep(NA, nrow(twas_modelInfo)),
                                                   bslmm.nsnps = rep(NA, nrow(twas_modelInfo)),lasso.nsnps = rep(NA, nrow(twas_modelInfo)),stringsAsFactors = F))
for(i in 1:nrow(twas_modelInfo)){
  print(i)
  load(sprintf('%s/CMC.BRAIN.RNASEQ/%s.wgt.RDat', twas_fold,twas_modelInfo$id[i]))
  names_type <- c('top1', 'blup', 'enet', 'bslmm', 'lasso')[!is.na(twas_modelInfo[i,c('top1.r2','blup.r2','enet.r2','bslmm.r2', 'lasso.r2')])]
  snps_name <- paste(names_type, 'nsnps', sep = '.')
  twas_modelInfo[i, snps_name] <- apply(wgt.matrix[, names_type],2, function(x) length(which(x!=0)))
}

# save
write.table(file = sprintf('%s/CMC.BRAIN.RNASEQ.profile_snpsUpdate', twas_fold), x = twas_modelInfo, sep = '\t', col.names = T, row.names = F, quote = F)

# extract best performing model
tmp <- twas_modelInfo[, 7:10]
id <- apply(tmp,1,which.max)
twas_modelInfo$best.r2 <- sapply(1:length(id), function(x) tmp[x, id[x]])
twas_modelInfo$best.pv <- sapply(1:length(id), function(x) twas_modelInfo[x, id[x]+11])
twas_modelInfo$best.nspns <- sapply(1:length(id), function(x) twas_modelInfo[x, id[x]+16])
twas_modelInfo$geneID <- sapply(twas_modelInfo$id, function(x) strsplit(x, split = 'CMC.')[[1]][2])

# prediXcan results
predix_fold <- '/psycl/g/mpsziller/lucia/CMC_DLPFC_prediXcan/Downloads/CMC_DLPFC-PrediXcan_Models/'
predix_modelInfo <- read.csv(paste0(predix_fold, 'extra.csv'), header = T, stringsAsFactors = F)


# load results PriLer
res_fold <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/train_All/200kb/'
priler_modelInfo <- read.table(sprintf('%s/resPrior_regEval_allchr.txt', res_fold), h=T, stringsAsFactors = F)
priler_beta <- get(load(sprintf('%s/resPrior_regCoeffSnps_allchr.RData', res_fold)))
n_snps = unlist(lapply(priler_beta, function(x) colSums(x != 0)))
priler_modelInfo$n_snps <- n_snps
# load number of snps in the window per gene
distMat <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/ENSEMBL_gene_SNP_2e+05_'
tmp <- c()
for(i in 1:22){
  print(i)
  geneSnpsMat <- readMM(sprintf('%schr%i_matrix.mtx',distMat, i))  
  tmp <- c(tmp,colSums(geneSnpsMat!=0))
}
priler_modelInfo$n_snps_gene_window <- tmp


########################
# find only common genes
df_priler_TWAS <- merge(y = twas_modelInfo, x = priler_modelInfo, by.y = 'geneID', by.x='external_gene_name', sort = F)
df_priler_predix <- merge(y = predix_modelInfo, x = priler_modelInfo, by.y = 'gene', by.x='ensembl_gene_id', sort = F)

## remove na
#df_priler_TWAS <- df_priler_TWAS[!is.na(df_priler_TWAS$test_comb_cor),]
#df_priler_predix <- df_priler_predix[!is.na(df_priler_predix$test_comb_cor),]

# save:
write.table(file = sprintf('%s/compare_PriLer_TWAS.txt', res_fold), x = df_priler_TWAS, sep = '\t', col.names = T, row.names = F, quote = F)
write.table(file = sprintf('%s/compare_PriLer_prediXcan.txt', res_fold), x = df_priler_predix, sep = '\t', col.names = T, row.names = F, quote = F)


