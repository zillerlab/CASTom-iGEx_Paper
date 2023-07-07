# CMC slurmgate: compute corelation between predicted GTEx on the entire set and cov corrected RNA (based on model)

setwd('/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2')
type <- c('Control50','Control100','Control150','ControlAll','All') 

rna_notrain <-  read.table(sprintf('pathwayAnalysis_OriginalRNA/train_%s/RNAseq_filt_covCorrected.txt', 'no'), h=T, stringsAsFactors = F, sep = '\t')
sampleAll <- read.table('train_All/covariateMatrix_All.txt', h=T, stringsAsFactors = F)

df_cor <- lapply(1:length(type), function(x) rna_notrain[, 1:9])
rna_notrain <- rna_notrain[, -(1:9)]
rna_notrain <- rna_notrain[, sapply(sampleAll$Individual_ID, function(x) which(colnames(rna_notrain) == x))]
rna_notrain <- t(rna_notrain)

for(i in 1:length(type)){
  
  print(i)
  
  df_cor[[i]]$cor_not <- NA
  df_cor[[i]]$cor_pval_not <- NA
  df_cor[[i]]$cor <- NA
  df_cor[[i]]$cor_pval <- NA
  
  
  tmp_pred <- read.table(gzfile(sprintf('predict_All/train_%s/200kb/predictedExpression.txt.gz', type[i])), h=T, stringsAsFactors = F, sep = '\t')
  tmp_rna <-  read.table(sprintf('pathwayAnalysis_OriginalRNA/train_%s/RNAseq_filt_covCorrected.txt', type[i]), h=T, stringsAsFactors = F, sep = '\t')
  if(!identical(tmp_pred$ensembl_gene_id, df_cor[[i]]$ensembl_gene_id)){
    id <- sapply(df_cor[[i]]$ensembl_gene_id, function(x) which(tmp_pred$ensembl_gene_id == x))
    tmp_pred <- tmp_pred[id, ]
  }
  if(!identical(tmp_pred$ensembl_gene_id, tmp_rna$ensembl_gene_id)){
    id <- sapply(tmp_pred$ensembl_gene_id, function(x) which(tmp_rna$ensembl_gene_id == x))
    tmp_rna <- tmp_rna[id, ]
  }
  
  tmp_pred <- tmp_pred[, sapply(sampleAll$Individual_ID, function(x) which(colnames(tmp_pred) == x))]
  tmp_rna <- tmp_rna[, sapply(sampleAll$Individual_ID, function(x) which(colnames(tmp_rna) == x))]
  
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
  write.table(df_cor[[i]], file = sprintf('predict_All/train_%s/200kb/corGenes_predAll_vs_covCorrRNA.txt', type[i]), col.names = T, row.names = F, sep = '\t', quote = F)
}

######################################### correlation pathway ######################################
pathR_notrain <-  read.delim(sprintf('pathwayAnalysis_OriginalRNA/train_%s/Pathway_Reactome_scores.txt', 'no'), h=T, stringsAsFactors = F, sep = '\t')
df_cor_pathR <- lapply(1:length(type), function(x) data.frame(path = pathR_notrain[,1], stringsAsFactors = F))

pathR_notrain <- pathR_notrain[, -1]
pathR_notrain <- pathR_notrain[, sapply(sampleAll$Individual_ID, function(x) which(colnames(pathR_notrain) == x))]
pathR_notrain <- t(pathR_notrain)

for(i in 1:length(type)){
  
  print(i)
  
  df_cor_pathR[[i]]$cor_not <- NA
  df_cor_pathR[[i]]$cor_pval_not <- NA
  df_cor_pathR[[i]]$cor <- NA
  df_cor_pathR[[i]]$cor_pval <- NA
  
  tmp_pred <- read.delim(sprintf('predict_All/train_%s/200kb/devgeno0.01_testdevgeno0/Pathway_Reactome_scores.txt', type[i]), h=T, stringsAsFactors = F, sep = '\t')
  tmp_rna <-  read.delim(sprintf('pathwayAnalysis_OriginalRNA/train_%s/Pathway_Reactome_scores.txt', type[i]), h=T, stringsAsFactors = F, sep = '\t')
  
  path_pred <- tmp_pred[, 1]
  path_rna <- tmp_rna[,1]

  tmp_pred <- tmp_pred[, sapply(sampleAll$Individual_ID, function(x) which(colnames(tmp_pred) == x))]
  tmp_rna <- tmp_rna[, sapply(sampleAll$Individual_ID, function(x) which(colnames(tmp_rna) == x))]
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
  write.table(df_cor_pathR[[i]], file = sprintf('predict_All/train_%s/200kb/devgeno0.01_testdevgeno0/corPathReactome_predAll_vs_covCorrRNA.txt', type[i]), col.names = T, row.names = F, sep = '\t', quote = F)
}

pathGO_notrain <-  read.delim(sprintf('pathwayAnalysis_OriginalRNA/train_%s/Pathway_GO_scores.txt', 'no'), h=T, stringsAsFactors = F, sep = '\t')
df_cor_pathGO <- lapply(1:length(type), function(x) data.frame(path = pathGO_notrain[,1], stringsAsFactors = F))

pathGO_notrain <- pathGO_notrain[, -1]
pathGO_notrain <- pathGO_notrain[, sapply(sampleAll$Individual_ID, function(x) which(colnames(pathGO_notrain) == x))]
pathGO_notrain <- t(pathGO_notrain)

for(i in 1:length(type)){
  
  print(i)
  
  df_cor_pathGO[[i]]$cor_not <- NA
  df_cor_pathGO[[i]]$cor_pval_not <- NA
  df_cor_pathGO[[i]]$cor <- NA
  df_cor_pathGO[[i]]$cor_pval <- NA
  
  tmp_pred <- read.delim(sprintf('predict_All/train_%s/200kb/devgeno0.01_testdevgeno0/Pathway_GO_scores.txt', type[i]), h=T, stringsAsFactors = F, sep = '\t')
  tmp_rna <-  read.delim(sprintf('pathwayAnalysis_OriginalRNA/train_%s/Pathway_GO_scores.txt', type[i]), h=T, stringsAsFactors = F, sep = '\t')
  
  path_pred <- tmp_pred[, 1]
  path_rna <- tmp_rna[,1]
  
  tmp_pred <- tmp_pred[, sapply(sampleAll$Individual_ID, function(x) which(colnames(tmp_pred) == x))]
  tmp_rna <- tmp_rna[, sapply(sampleAll$Individual_ID, function(x) which(colnames(tmp_rna) == x))]
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
  write.table(df_cor_pathGO[[i]], file = sprintf('predict_All/train_%s/200kb/devgeno0.01_testdevgeno0/corPathGO_predAll_vs_covCorrRNA.txt', type[i]), col.names = T, row.names = F, sep = '\t', quote = F)

}

####
# save in a unique file number of genes and pathway for each configuaration (wrt sample size)
####

df_tot <- data.frame(type = type, n_samples = 0, n_genes = 0, n_pathR = 0, n_pathGO = 0, stringsAsFactors = F)
for(i in 1:length(type)){
  
  sample_ann <- read.table(sprintf('train_%s/covariateMatrix_%s.txt', type[i], type[i]), h=T, stringsAsFactors = F)
  df_tot$n_samples[i] <- nrow(sample_ann)
  geneEval <- read.table(sprintf('train_%s/200kb/resPrior_regEval_allchr.txt', type[i]), h=T, stringsAsFactors = F, sep = '\t')
  df_tot$n_genes[i] <- length(which(geneEval$test_dev_geno>0 & geneEval$dev_geno>0.01))
  pathR <- read.delim(sprintf('predict_All/train_%s/200kb/devgeno0.01_testdevgeno0/Pathway_Reactome_scores.txt', type[i]), h=T, stringsAsFactors = F, sep = '\t')
  df_tot$n_pathR[i] <- nrow(pathR)
  pathGO <- read.delim(sprintf('predict_All/train_%s/200kb/devgeno0.01_testdevgeno0/Pathway_GO_scores.txt', type[i]), h=T, stringsAsFactors = F, sep = '\t')
  df_tot$n_pathGO[i] <- nrow(pathGO)

}
write.table(df_tot, file = sprintf('nSamples_nRelGenes.txt'), col.names = T, row.names = F, sep = '\t', quote = F)





