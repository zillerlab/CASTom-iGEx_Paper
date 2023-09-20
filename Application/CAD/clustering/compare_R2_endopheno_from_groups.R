# compute R2 for a phenotype when wrt a certain partition (or PRS)

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(doParallel))
suppressPackageStartupMessages(library(qvalue))
suppressPackageStartupMessages(library(pROC))
suppressPackageStartupMessages(library(pryr))
suppressPackageStartupMessages(library(umap))
suppressPackageStartupMessages(library(igraph))
suppressPackageStartupMessages(library(Matrix))
suppressPackageStartupMessages(library(SparseM))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(pheatmap))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(data.table))
options(bitmapType = 'cairo', device = 'png')

parser <- ArgumentParser(description="R2 from phenotype - group/PRS")
parser$add_argument("--cluster_file", type = "character", default = NULL, help = "")
parser$add_argument("--PRS_file", type = "character", default = NULL, help = "")
parser$add_argument("--sampleAnn_file", type = "character", help = "")
parser$add_argument("--pheno_file", type = "character", help = "")
parser$add_argument("--phenoAnn_file", type = "character", help = "")
parser$add_argument("--outFold", type="character", help = "Output file [basename only]")

args <- parser$parse_args()
cluster_file <- args$cluster_file
PRS_file <- args$PRS_file
sampleAnn_file <- args$sampleAnn_file
pheno_file <- args$pheno_file
phenoAnn_file <- args$phenoAnn_file
outFold <- args$outFold

###################################################################################################################
#setwd("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/")
#sampleAnn_file <- 'INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt'
#outFold <- 'OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/'
#PRS_file <- 'OUTPUT_GWAS/PRS/PRS_CAD_UKBB.best'
## cluster_file <- 'OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData'
#cluster_file <- 'OUTPUT_GWAS/PRS/PRS_CAD_UKBB_Cases_deciles.RData'
#pheno_file <- 'INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/phenotypeMatrix_CADHARD_All_phenoAssoc_withMedication.txt'
#phenoAnn_file <- 'INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/phenotypeDescription_withMedication.txt'
##################################################################################################################

##############################################
# function to evaluate rs-phenotype
R2_risk_score <- function(fmla, fmla_cov, type_pheno, mat){
  
  R2_tot <- NA
  R2_cov <- NA
  R2_diff <- NA
  Fstat_diff <- NA
  N <- sum(!is.na(mat$pheno))
  
  res <- tryCatch(lm(fmla, data = mat),warning=function(...) NA, error=function(...) NA)
  if(is.list(res)){
    s_res <- summary(res)
    # R2_tot <- 1-s_res$deviance/s_res$null.deviance
    R2_tot <- s_res$r.squared  
  }
  
  res_cov <- tryCatch(lm(fmla_cov, data = mat),warning=function(...) NA, error=function(...) NA)
  if(is.list(res_cov)){
    s_res_cov <- summary(res_cov)
    # R2_cov <- 1-s_res$deviance/s_res$null.deviance
    R2_cov <- s_res_cov$r.squared  
  }
  
  if(is.list(res_cov) & is.list(res)){
    R2_diff <- R2_tot - R2_cov
    # Fstat_diff <- (N-nrow(s_res$coefficients))*(sum(s_res_cov$residuals^2) - sum(s_res$residuals^2))/sum(s_res$residuals^2)
    comp_mod <- anova(res_cov, res)
    Fstat_diff <-  comp_mod$F[2]
    Fstat_pval <- comp_mod[2,6]

  }
  
  return(c(R2_diff, Fstat_diff, Fstat_pval, R2_tot, R2_cov))
  
}
##############################################

sampleAnn <- read.table(sampleAnn_file, h=T, stringsAsFactors = F)
pheno <- fread(pheno_file, h=T, stringsAsFactors = F, data.table = F)
phenoAnn <- fread(phenoAnn_file, h=T, stringsAsFactors = F)

cl <- get(load(cluster_file))
cl_res <- cl$cl_best
cl_res$gr <- as.factor(cl_res$gr)

if(!is.null(PRS_file)){
    PRS <- read.table(PRS_file, h=T, stringsAsFactors = F)
    PRS <- PRS[match(cl_res$id, paste0("X", PRS$FID)), ]
    PRS <- PRS[, c('FID', 'PRS')]
}

common_s <- intersect(cl_res$id, sampleAnn$Individual_ID)
sampleAnn <- sampleAnn[match(common_s, sampleAnn$Individual_ID), ]
pheno <- pheno[match(common_s, pheno$Individual_ID), ]
covDat <- sampleAnn[, !colnames(sampleAnn) %in% c('Individual_ID', 'Dx', 'genoSample_ID')]

cl_variables <- model.matrix( ~ 0 + gr, data = cl_res)
# get variables
fmla_cov <- as.formula(paste('pheno~', paste0(colnames(covDat), collapse = '+')))
fmla <- as.formula(paste('pheno~', paste0(colnames(cl_variables), collapse = '+'), '+', paste0(colnames(covDat), collapse = '+')))

summary_res <- list()
for(i in 1:nrow(phenoAnn)){
  
  print(phenoAnn$pheno_id[i])
  
  pheno_tmp <- pheno[, colnames(pheno) %in% phenoAnn$pheno_id[i], drop = F]
  summary_res[[i]] <- data.frame(pheno_id = colnames(pheno_tmp), 
                                 R2_group = NA, 
                                 Fstat_group = NA,
                                 Fpval_group = NA,
                                 R2_tot = NA, 
                                 R2_cov = NA, 
                                 nsamples = NA, 
                                 nsamples_T = NA)
  mat <- cbind(data.frame(pheno = pheno_tmp[,1]), cl_variables, covDat)
  type_pheno <- phenoAnn$transformed_type[phenoAnn$pheno_id == colnames(pheno_tmp)[1]]
  tmp <- R2_risk_score(fmla = fmla, fmla_cov = fmla_cov, type_pheno = type_pheno, mat = mat)
  summary_res[[i]][1, 2:6] <- tmp
  summary_res[[i]]$nsamples <- sum(!is.na(mat$pheno))
  if(!type_pheno %in% c('CONTINUOUS', 'CAT_ORD')){
      summary_res[[i]]$nsamples_T <- sum(pheno_tmp[,1] == 1 & !is.na(mat$pheno))
    }
}

# save results
summary_res <- do.call(rbind, summary_res)
summary_res <- cbind(summary_res, phenoAnn[match(summary_res$pheno_id, phenoAnn$pheno_id), 
                                           c('Field', 'Coding_meaning', 'transformed_type')])

write.table(file = sprintf('%sgroup_phenotype_R2.txt', outFold), 
            x = summary_res, quote = F, sep = '\t', col.names = T, row.names = F)


# PRS
if(!is.null(PRS_file)){

    # get variables
    fmla_cov <- as.formula(paste('pheno~', paste0(colnames(covDat), collapse = '+')))
    fmla <- as.formula(paste('pheno~PRS+', paste0(colnames(covDat), collapse = '+')))

    summary_res <- list()
    for(i in 1:nrow(phenoAnn)){
  
        print(phenoAnn$pheno_id[i])
  
        pheno_tmp <- pheno[, colnames(pheno) %in% phenoAnn$pheno_id[i], drop = F]
        summary_res[[i]] <- data.frame(pheno_id = colnames(pheno_tmp), 
                                 R2_group = NA, 
                                 Fstat_group = NA,
                                 Fpval_group = NA,
                                 R2_tot = NA, 
                                 R2_cov = NA, 
                                 nsamples = NA, 
                                 nsamples_T = NA)
        mat <- cbind(data.frame(pheno = pheno_tmp[,1], PRS = PRS$PRS), covDat)
        type_pheno <- phenoAnn$transformed_type[phenoAnn$pheno_id == colnames(pheno_tmp)[1]]
        tmp <- R2_risk_score(fmla = fmla, fmla_cov = fmla_cov, type_pheno = type_pheno, mat = mat)
        summary_res[[i]][1, 2:6] <- tmp
        summary_res[[i]]$nsamples <- sum(!is.na(mat$pheno))
        if(!type_pheno %in% c('CONTINUOUS', 'CAT_ORD')){
         summary_res[[i]]$nsamples_T <- sum(pheno_tmp[,1] == 1 & !is.na(mat$pheno))
        }
    }

    # save results
    summary_res <- do.call(rbind, summary_res)
    summary_res <- cbind(summary_res, phenoAnn[match(summary_res$pheno_id, phenoAnn$pheno_id), 
                                               c('Field', 'Coding_meaning', 'transformed_type')])

    write.table(file = sprintf('%sPRS_phenotype_R2.txt', outFold), 
            x = summary_res, quote = F, sep = '\t', col.names = T, row.names = F)

}