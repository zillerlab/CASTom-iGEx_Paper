# GTEx on denbi:
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

# each tissue can have a different model: noGWAS, CAD_GWAS, PGC_GWAS
tissues_model <- read.csv('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv', h=F, stringsAsFactors = F)
colnames(tissues_model) <- c('tissue', 'type')
tissues_model$folder <- sapply(tissues_model$tissue, function(x) sprintf('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/%s/200kb/noGWAS/', x))
tissues_model$folder[tissues_model$type == 'CAD'] <- sapply(tissues_model$tissue[tissues_model$type == 'CAD'] , function(x) sprintf('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/%s/200kb/CAD_GWAS_bin5e-2/', x))
tissues_model$folder[tissues_model$type == 'PGC'] <- sapply(tissues_model$tissue[tissues_model$type == 'PGC'], function(x) sprintf('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/%s/200kb/PGC_GWAS_bin1e-2/', x))

TWAS_fold_v7 <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v7/'
TWAS_fold_v6p <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v6p/'
predix_fold_v7 <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prediXcan/GTEx_v7/'
predix_fold_v6p <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prediXcan/GTEx_v6p/TW_'

for(t in tissues_model$tissue){
    
  print(t)
  
  # load TWAS (GTEx v7)
  twas_v7_modelInfo <- read.table(sprintf('%s/%s/gene.profile', TWAS_fold_v7, t), h=T)
  # extract best performing model
  tmp <- twas_v7_modelInfo[, 7:9]
  id <- apply(tmp,1,which.max)
  twas_v7_modelInfo$best.r2 <- sapply(1:length(id), function(x) tmp[x, id[x]])
  twas_v7_modelInfo$best.pv <- sapply(1:length(id), function(x) twas_v7_modelInfo[x, id[x]+9])
  twas_v7_modelInfo$best.nsnps <- sapply(1:length(id), function(x) twas_v7_modelInfo[x, id[x]+12])
  twas_v7_modelInfo$ensemble_gene_id_new <- sapply(twas_v7_modelInfo$ensemble_gene_id, function(x) strsplit(x, split = '[.]')[[1]][1])
  
  # load TWAS (GTEx v6p)
  twas_v6p_modelInfo <- read.table(sprintf('%s/GTEx.%s/gene.profile', TWAS_fold_v6p, t), h=T)
  # extract best performing model
  tmp <- twas_v6p_modelInfo[, 7:10]
  id <- apply(tmp,1,which.max)
  twas_v6p_modelInfo$best.r2 <- sapply(1:length(id), function(x) tmp[x, id[x]])
  twas_v6p_modelInfo$best.pv <- sapply(1:length(id), function(x) twas_v6p_modelInfo[x, id[x]+10])
  twas_v6p_modelInfo$best.nsnps <- sapply(1:length(id), function(x) twas_v6p_modelInfo[x, id[x]+14])
  twas_v6p_modelInfo$ensemble_gene_id_new <- sapply(twas_v6p_modelInfo$ensemble_gene_id, function(x) strsplit(x, split = '[.]')[[1]][1])
  
  # load prediXcan (v6p)
  predix_v6p_modelInfo <- read.table(sprintf('%s%s/extra.txt', predix_fold_v6p, t), h=T)
  # load prediXcan (v7)
  predix_v7_modelInfo <- read.table(sprintf('%s%s/extra.txt', predix_fold_v7, t), h=T)
  
  # load results PriLer
  priler_modelInfo <- read.table(sprintf('%s/resPrior_regEval_allchr.txt', tissues_model$folder[tissues_model$tissue == t]), h=T, stringsAsFactors = F)
  priler_beta <- get(load(sprintf('%s/resPrior_regCoeffSnps_allchr.RData', tissues_model$folder[tissues_model$tissue == t])))
  n_snps = unlist(lapply(priler_beta, function(x) colSums(x != 0)))
  priler_modelInfo$n_snps <- n_snps
  # load number of snps in the window per gene
  distMat <- sprintf('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/%s/ENSEMBL_gene_SNP_2e+05_', t)
  tmp <- c()
  for(i in 1:22){
    print(i)
    geneSnpsMat <- readMM(sprintf('%schr%i_matrix.mtx',distMat, i))  
    tmp <- c(tmp,colSums(geneSnpsMat!=0))
  }
  priler_modelInfo$n_snps_gene_window <- tmp
  
  ########################
  # find only common genes
  df_priler_TWAS_v7 <- merge(y = twas_v7_modelInfo, x = priler_modelInfo, by.y = 'geneName', by.x='external_gene_name', sort = F)
  df_priler_TWAS_v6p <- merge(y = twas_v6p_modelInfo, x = priler_modelInfo, by.y = 'geneName', by.x='external_gene_name', sort = F)
  df_priler_predix_v7 <- merge(y = predix_v7_modelInfo, x = priler_modelInfo, by.y = 'genename', by.x='external_gene_name', sort = F)
  df_priler_predix_v6p <- merge(y = predix_v6p_modelInfo, x = priler_modelInfo, by.y = 'genename', by.x='external_gene_name', sort = F)
  
  # save:
  write.table(file = sprintf('%s/compare_PriLer_TWAS_v7.txt', tissues_model$folder[tissues_model$tissue == t]), x = df_priler_TWAS_v7, sep = '\t', col.names = T, row.names = F, quote = F)
  write.table(file = sprintf('%s/compare_PriLer_TWAS_v6p.txt', tissues_model$folder[tissues_model$tissue == t]), x = df_priler_TWAS_v6p, sep = '\t', col.names = T, row.names = F, quote = F)
  write.table(file = sprintf('%s/compare_PriLer_prediXcan_v7.txt', tissues_model$folder[tissues_model$tissue == t]), x =  df_priler_predix_v7, sep = '\t', col.names = T, row.names = F, quote = F)
  write.table(file = sprintf('%s/compare_PriLer_prediXcan_v6p.txt', tissues_model$folder[tissues_model$tissue == t]), x =  df_priler_predix_v6p, sep = '\t', col.names = T, row.names = F, quote = F)

}
