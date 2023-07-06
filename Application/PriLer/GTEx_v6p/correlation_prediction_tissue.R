# GTEx slurmgate: compute correlation between predicted on the entire set and cov corrected RNA (based on model)

setwd('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2')
# each tissue can have a different model: noGWAS, CAD_GWAS, PGC_GWAS
tissues_model <- read.csv('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv', h=F, stringsAsFactors = F)
colnames(tissues_model) <- c('tissue', 'type')
tissues_model$folder <- sapply(tissues_model$tissue, function(x) sprintf('%s/200kb/noGWAS/', x))
tissues_model$folder[tissues_model$type == 'CAD'] <- sapply(tissues_model$tissue[tissues_model$type == 'CAD'] , function(x) sprintf('%s/200kb/CAD_GWAS_bin5e-2/', x))
tissues_model$folder[tissues_model$type == 'PGC'] <- sapply(tissues_model$tissue[tissues_model$type == 'PGC'], function(x) sprintf('%s/200kb/PGC_GWAS_bin1e-2/', x))
tissues_model$folder_rna <- sapply(tissues_model$tissue, function(x) sprintf('pathwayAnalysis_OriginalRNA/%s/noGWAS/', x))
tissues_model$folder_rna[tissues_model$type == 'CAD'] <- sapply(tissues_model$tissue[tissues_model$type == 'CAD'] , function(x) sprintf('pathwayAnalysis_OriginalRNA/%s/CAD_GWAS_bin5e-2/', x))
tissues_model$folder_rna[tissues_model$type == 'PGC'] <- sapply(tissues_model$tissue[tissues_model$type == 'PGC'], function(x) sprintf('pathwayAnalysis_OriginalRNA/%s/PGC_GWAS_bin1e-2/', x))
tissues_model$folder_pred <- sapply(tissues_model$tissue, function(x) sprintf('predict_GTEx/%s/noGWAS/', x))
tissues_model$folder_pred[tissues_model$type == 'CAD'] <- sapply(tissues_model$tissue[tissues_model$type == 'CAD'] , function(x) sprintf('predict_GTEx/%s/CAD_GWAS_bin5e-2/', x))
tissues_model$folder_pred[tissues_model$type == 'PGC'] <- sapply(tissues_model$tissue[tissues_model$type == 'PGC'], function(x) sprintf('predict_GTEx/%s/PGC_GWAS_bin1e-2/', x))
tissues_model$folder_rna_notrain <- sapply(tissues_model$tissue, function(x) sprintf('pathwayAnalysis_OriginalRNA/%s/no_train/', x))

df_cor <- list()
df_cor_pathR <- list()
df_cor_pathGO <- list()

for(i in 1:nrow(tissues_model)){
  
  print(tissues_model$tissue[i])
  sampleAnn <- read.table(sprintf('../INPUT_DATA/Covariates/%s/covariates_EuropeanSamples.txt', tissues_model$tissue[i]), h=T, stringsAsFactors = F)
  rna_notrain <-  read.table(sprintf('%s/RNAseq_filt_covCorrected.txt', tissues_model$folder_rna_notrain[i]), h=T, stringsAsFactors = F, sep = '\t', check.names = F)
  
  df_cor[[i]] <- rna_notrain[, 1:9]
  rna_notrain <- rna_notrain[, -(1:9)]
  rna_notrain <- rna_notrain[, sapply(sampleAnn$Individual_ID, function(x) which(colnames(rna_notrain) == x))]
  rna_notrain <- t(rna_notrain)
  
  df_cor[[i]]$cor_not <- NA
  df_cor[[i]]$cor_pval_not <- NA
  df_cor[[i]]$cor <- NA
  df_cor[[i]]$cor_pval <- NA
  
  tmp_pred <- read.table(gzfile(sprintf('%s/predictedExpression.txt.gz', tissues_model$folder_pred[i])), h=T, stringsAsFactors = F, sep = '\t', check.names = F)
  tmp_rna <-  read.table(sprintf('%s/RNAseq_filt_covCorrected.txt',  tissues_model$folder_rna[i]), h=T, stringsAsFactors = F, sep = '\t', check.names = F)
  if(!identical(tmp_pred$ensembl_gene_id, df_cor[[i]]$ensembl_gene_id)){
    id <- sapply(df_cor[[i]]$ensembl_gene_id, function(x) which(tmp_pred$ensembl_gene_id == x))
    tmp_pred <- tmp_pred[id, ]
  }
  if(!identical(tmp_pred$ensembl_gene_id, tmp_rna$ensembl_gene_id)){
    id <- sapply(tmp_pred$ensembl_gene_id, function(x) which(tmp_rna$ensembl_gene_id == x))
    tmp_rna <- tmp_rna[id, ]
  }
  
  tmp_pred <- tmp_pred[, sapply(sampleAnn$Individual_ID, function(x) which(colnames(tmp_pred) == x))]
  tmp_rna <- tmp_rna[, sapply(sampleAnn$Individual_ID, function(x) which(colnames(tmp_rna) == x))]
  
  tmp_pred <- t(tmp_pred)
  tmp_rna <- t(tmp_rna)
  
  for(j in 1:ncol(tmp_pred)){
    # print(j)
    tmp1 <- cor.test(tmp_pred[,j], tmp_rna[,j])
    tmp2 <- cor.test(tmp_pred[,j], rna_notrain[,j])
    df_cor[[i]]$cor_not[j] <-  tmp2$est
    df_cor[[i]]$cor_pval_not[j] <-  tmp2$p.value
    df_cor[[i]]$cor[j] <-  tmp1$est
    df_cor[[i]]$cor_pval[j] <-  tmp1$p.value
    
  }
  # save in a different folder for each type
  write.table(df_cor[[i]], file = sprintf('%s/corGenes_predAll_vs_covCorrRNA.txt', tissues_model$folder_pred[i]), col.names = T, row.names = F, sep = '\t', quote = F)
  
  #### path R ####
  pathR_notrain <-  read.delim(sprintf('%sPathway_Reactome_scores.txt', tissues_model$folder_rna_notrain[i]), h=T, stringsAsFactors = F, sep = '\t', check.names = F)
  df_cor_pathR[[i]] <- data.frame(path = pathR_notrain[,1], stringsAsFactors = F)
  pathR_notrain <- pathR_notrain[, unlist(sapply(sampleAnn$Individual_ID, function(x) which(colnames(pathR_notrain) == x)))]
  pathR_notrain <- t(pathR_notrain)
  
  df_cor_pathR[[i]]$cor_not <- NA
  df_cor_pathR[[i]]$cor_pval_not <- NA
  df_cor_pathR[[i]]$cor <- NA
  df_cor_pathR[[i]]$cor_pval <- NA
  
  tmp_pred <- read.delim(sprintf('%s/devgeno0.01_testdevgeno0/Pathway_Reactome_scores.txt', tissues_model$folder_pred[i]), h=T, stringsAsFactors = F, sep = '\t', check.names = F)
  tmp_rna <-  read.delim(sprintf('%s/Pathway_Reactome_scores.txt', tissues_model$folder_rna[i]), h=T, stringsAsFactors = F, sep = '\t', check.names = F)
  
  path_pred <- tmp_pred[, 1]
  path_rna <- tmp_rna[,1]
  
  tmp_pred <- tmp_pred[, unlist(sapply(sampleAnn$Individual_ID, function(x) which(colnames(tmp_pred) == x)))]
  tmp_rna <- tmp_rna[, unlist(sapply(sampleAnn$Individual_ID, function(x) which(colnames(tmp_rna) == x)))]
  tmp_pred <- t(tmp_pred)
  tmp_rna <- t(tmp_rna)
  
  for(j in 1:nrow(df_cor_pathR[[i]])){
    
    # print(j)
    
    id1 <- which(df_cor_pathR[[i]]$path[j] == path_pred)
    id2 <- which(df_cor_pathR[[i]]$path[j] == path_rna)
    
    if(length(id1)>0){
      tmp1 <- cor.test(tmp_pred[,id1], pathR_notrain[,j])
      df_cor_pathR[[i]]$cor_not[j] <-  tmp1$est
      df_cor_pathR[[i]]$cor_pval_not[j] <-  tmp1$p.value
      
    }
    if(length(id1)>0 & length(id2)>0){
      tmp2 <- cor.test(tmp_pred[,id1], tmp_rna[,id2])
      df_cor_pathR[[i]]$cor[j] <-  tmp2$est
      df_cor_pathR[[i]]$cor_pval[j] <-  tmp2$p.value
    }
    
  }
  
  # save in a different folder for each type
  write.table(df_cor_pathR[[i]], file = sprintf('%s/corPathReactome_predAll_vs_covCorrRNA.txt', tissues_model$folder_pred[i]), col.names = T, row.names = F, sep = '\t', quote = F)
  
  #### path GO ####
  pathGO_notrain <-  read.delim(sprintf('%sPathway_GO_scores.txt', tissues_model$folder_rna_notrain[i]), h=T, stringsAsFactors = F, sep = '\t', check.names = F)
  df_cor_pathGO[[i]] <- data.frame(path = pathGO_notrain[,1], stringsAsFactors = F)
  pathGO_notrain <- pathGO_notrain[, unlist(sapply(sampleAnn$Individual_ID, function(x) which(colnames(pathGO_notrain) == x)))]
  pathGO_notrain <- t(pathGO_notrain)
  
  df_cor_pathGO[[i]]$cor_not <- NA
  df_cor_pathGO[[i]]$cor_pval_not <- NA
  df_cor_pathGO[[i]]$cor <- NA
  df_cor_pathGO[[i]]$cor_pval <- NA
  
  tmp_pred <- read.delim(sprintf('%s/devgeno0.01_testdevgeno0/Pathway_GO_scores.txt', tissues_model$folder_pred[i]), h=T, stringsAsFactors = F, sep = '\t', check.names = F)
  tmp_rna <-  read.delim(sprintf('%s/Pathway_GO_scores.txt', tissues_model$folder_rna[i]), h=T, stringsAsFactors = F, sep = '\t', check.names = F)
  
  path_pred <- tmp_pred[, 1]
  path_rna <- tmp_rna[,1]
  
  tmp_pred <- tmp_pred[, unlist(sapply(sampleAnn$Individual_ID, function(x) which(colnames(tmp_pred) == x)))]
  tmp_rna <- tmp_rna[, unlist(sapply(sampleAnn$Individual_ID, function(x) which(colnames(tmp_rna) == x)))]
  tmp_pred <- t(tmp_pred)
  tmp_rna <- t(tmp_rna)
  
  for(j in 1:nrow(df_cor_pathGO[[i]])){
    
    # print(j)
    
    id1 <- which(df_cor_pathGO[[i]]$path[j] == path_pred)
    id2 <- which(df_cor_pathGO[[i]]$path[j] == path_rna)
    
    if(length(id1)>0){
      tmp1 <- cor.test(tmp_pred[,id1], pathGO_notrain[,j])
      df_cor_pathGO[[i]]$cor_not[j] <-  tmp1$est
      df_cor_pathGO[[i]]$cor_pval_not[j] <-  tmp1$p.value
      
    }
    if(length(id1)>0 & length(id2)>0){
      tmp2 <- cor.test(tmp_pred[,id1], tmp_rna[,id2])
      df_cor_pathGO[[i]]$cor[j] <-  tmp2$est
      df_cor_pathGO[[i]]$cor_pval[j] <-  tmp2$p.value
    }
    
  }
  
  # save in a different folder for each type
  write.table(df_cor_pathGO[[i]], file = sprintf('%s/corPathGO_predAll_vs_covCorrRNA.txt', tissues_model$folder_pred[i]), col.names = T, row.names = F, sep = '\t', quote = F)
  
}


####
# save in a unique file number of genes and pathway for each configuaration (wrt sample size)
####

df_tot <- data.frame(type = tissues_model$tissue, n_samples = 0, n_genes = 0, n_pathR = 0, n_pathGO = 0, stringsAsFactors = F)
for(i in 1:nrow(tissues_model)){
  print(i)
  sample_ann <- read.table(sprintf('../INPUT_DATA/Covariates/%s/covariates_EuropeanSamples.txt', tissues_model$tissue[i]), h=T, stringsAsFactors = F)
  df_tot$n_samples[i] <- nrow(sample_ann)
  geneEval <- read.table(sprintf('%s/resPrior_regEval_allchr.txt',tissues_model$folder[i]), h=T, stringsAsFactors = F, sep = '\t')
  df_tot$n_genes[i] <- length(which(geneEval$test_dev_geno>0 & geneEval$dev_geno>0.01))
  pathR <- read.delim(sprintf('%s/devgeno0.01_testdevgeno0/Pathway_Reactome_scores.txt', tissues_model$folder_pred[i]), h=T, stringsAsFactors = F, sep = '\t')
  df_tot$n_pathR[i] <- nrow(pathR)
  pathGO <- read.delim(sprintf('%s/devgeno0.01_testdevgeno0/Pathway_GO_scores.txt', tissues_model$folder_pred[i]), h=T, stringsAsFactors = F, sep = '\t')
  df_tot$n_pathGO[i] <- nrow(pathGO)

}
write.table(df_tot, file = sprintf('nSamples_nRelGenes.txt'), col.names = T, row.names = F, sep = '\t', quote = F)





