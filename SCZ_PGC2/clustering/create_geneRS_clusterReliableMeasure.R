# build CRM for gene-RS group-specific differences

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(e1071))
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
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(ggsci))
options(bitmapType = 'cairo', device = 'png')


###################################################################################################################
setwd('/psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT')
#################################################################################################################


create_complete_table <- function(riskScore_res_file, R2_file, phenoInfo, save_file){
  
  rs_res <- read.delim(riskScore_res_file, h=T, stringsAsFactors = F, sep = '\t')
  rs_res <- rs_res[!is.na(rs_res$pvalue), ]
  R2_pheno_rs <- read.delim(R2_file, h=T, stringsAsFactors = F, sep = '\t')
  common_pheno <- intersect(R2_pheno_rs$pheno_id, unique(rs_res$pheno_id))
  R2_pheno_rs <- R2_pheno_rs[match(common_pheno, R2_pheno_rs$pheno_id),]
  rs_res_comp <- rs_res[rs_res$pheno_id %in% common_pheno,]
  
  # add measure info
  comp_name <- sort(unique(rs_res_comp$comp))
  rs_res_withmeas <- list()
  for(i in 1:length(comp_name)){
    
    tmp_rs <- rs_res_comp[rs_res_comp$comp %in% comp_name[i], ]
    c_pheno_tmp <- intersect(R2_pheno_rs$pheno_id, tmp_rs$pheno_id)
    tmp_rs <- tmp_rs[match(c_pheno_tmp, tmp_rs$pheno_id),]
    tmp_R2 <- R2_pheno_rs[match(c_pheno_tmp, R2_pheno_rs$pheno_id) , ]
    tmp_rs$R2_risk <- tmp_R2$R2_risk
    tmp_rs$Fstat_risk <- tmp_R2$Fstat_risk
    tmp_rs$measure <- tmp_rs$Fstat*abs(tmp_rs$beta)
    tmp_info <- phenoInfo[match(c_pheno_tmp, phenoInfo$pheno_id),]
    tmp_rs$pheno_type <- tmp_info$pheno_type
    rs_res_withmeas[[i]] <- tmp_rs
    
  }
  rs_res_withmeas <- do.call(rbind, rs_res_withmeas)
  # save updated table
  write.table(x = rs_res_withmeas, 
              file = save_file, 
              col.names = T, row.names = F, sep = '\t', quote = F)
  
}


phenoInfo_file <- '/psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/phenotypeDescription_rsSCZ_updated.txt'
phenoInfo <- read.delim(phenoInfo_file, header = T, stringsAsFactors = F, sep = '\t')
if(!'pheno_type' %in% colnames(phenoInfo)){
  tmp_name <- sapply(phenoInfo$Path, function(x) strsplit(x, split = '> ')[[1]][length(strsplit(x, split = '> ')[[1]])])
  tmp_name <- sapply(tmp_name, function(x) paste0(strsplit(x, split = ' ')[[1]], collapse = '_'))
  phenoInfo$pheno_type <- tmp_name
  phenoInfo$pheno_type[phenoInfo$pheno_type == 'Summary_Information_(diagnoses)'] <- 'ICD9-10_OPCS4'
}

#### DLPC:
# 0.9
riskScore_res_file <-  'clustering_res_matchUKBB_corrPCs/DLPC_CMC/matchUKBB_riskScores_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt'
R2_file <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/update_corrPCs/matchPGC_tscore_corr2Thr0.1_relatedPhenotypes_R2_risk_score_phenotype.txt'
out_file <- paste0('clustering_res_matchUKBB_corrPCs/DLPC_CMC/matchUKBB_riskScores_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM_annotated.txt')
create_complete_table(riskScore_res_file = riskScore_res_file, R2_file = R2_file, phenoInfo = phenoInfo, save_file = out_file) 

# 0.1
riskScore_res_file <-  'clustering_res_matchUKBB_corrPCs/DLPC_CMC/matchUKBB_filt0.1_riskScores_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt'
R2_file <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/update_corrPCs/matchPGC_tscore_corr2Thr0.1_relatedPhenotypes_R2_risk_score_phenotype.txt'
out_file <- paste0('clustering_res_matchUKBB_corrPCs/DLPC_CMC/matchUKBB_filt0.1_riskScores_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM_annotated.txt')
create_complete_table(riskScore_res_file = riskScore_res_file, R2_file = R2_file, phenoInfo = phenoInfo, save_file = out_file) 

# 0.9 between groups with controls
riskScore_res_file <-  'clustering_res_matchUKBB_corrPCs/DLPC_CMC/matchUKBB_allSamples_riskScores_tscore_corrPCs_zscaled_clusterAll_PGmethod_HKmetric_phenoAssociation_GLMpairwise.txt'
R2_file <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/update_corrPCs/matchPGC_tscore_corr2Thr0.1_relatedPhenotypes_R2_risk_score_phenotype.txt'
out_file <- paste0('clustering_res_matchUKBB_corrPCs/DLPC_CMC/matchUKBB_allSamples_riskScores_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM_annotated.txt')
create_complete_table(riskScore_res_file = riskScore_res_file, R2_file = R2_file, phenoInfo = phenoInfo, save_file = out_file) 

#### GTEx tissues:
tissues <- read.table('Tissues_all', h=F, stringsAsFactors = F)$V1[-1]
common_path <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_UKBB/'
for(id_t in 1:length(tissues)){
  
  t <- tissues[id_t]
  # 0.9
  riskScore_res_file <-  paste0('clustering_res_matchUKBB_corrPCs/',t,'/matchUKBB_riskScores_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt')
  R2_file <- paste0(common_path, t,'/200kb/noGWAS/devgeno0.01_testdevgeno0/update_corrPCs/matchPGC_tscore_corr2Thr0.1_relatedPhenotypes_R2_risk_score_phenotype.txt')
  out_file <- paste0('clustering_res_matchUKBB_corrPCs/',t,'/matchUKBB_riskScores_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM_annotated.txt')
  create_complete_table(riskScore_res_file = riskScore_res_file, R2_file = R2_file, phenoInfo = phenoInfo, save_file = out_file) 
  
  # 0.1
  riskScore_res_file <-  paste0('clustering_res_matchUKBB_corrPCs/',t,'/matchUKBB_filt0.1_riskScores_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt')
  R2_file <- paste0(common_path, t,'/200kb/noGWAS/devgeno0.01_testdevgeno0/update_corrPCs/matchPGC_tscore_corr2Thr0.1_relatedPhenotypes_R2_risk_score_phenotype.txt')
  out_file <- paste0('clustering_res_matchUKBB_corrPCs/',t,'/matchUKBB_filt0.1_riskScores_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM_annotated.txt')
  create_complete_table(riskScore_res_file = riskScore_res_file, R2_file = R2_file, phenoInfo = phenoInfo, save_file = out_file) 
  
}


