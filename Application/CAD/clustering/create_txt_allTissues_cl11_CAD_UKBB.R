# combine all tissues results (CAD)
library(qvalue)
library(data.table)
library(rlist)

setwd('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/')
tissues_name <- c('Adipose_Subcutaneous', 'Adipose_Visceral_Omentum', 'Adrenal_Gland', 'Artery_Aorta', 'Artery_Coronary', 'Colon_Sigmoid', 'Colon_Transverse', 'Heart_Atrial_Appendage','Heart_Left_Ventricle', 'Liver', 'Whole_Blood')
bp_loci <- 1000000
cis_size <- 200000

df_tscore <- df_pathR <- df_pathGO <- list()
df_pathWiki <- list()
##################
for(i in 1:length(tissues_name)){
  
  t <- tissues_name[i]
  print(t)
  
  tmp <- get(load(sprintf('predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/cluster_specific_PALAS/%s/pval_ClusterCasesVSControls_pheno_covCorr.RData', t)))
  n_gr <- length(tmp$tscore)
  df_tscore[[i]] <- list()
  df_pathR[[i]] <- list()
  df_pathGO[[i]] <- list()

  for(j in 1:n_gr){

    tmp$tscore[[j]]$tissue <- t
    tmp$pathScore_reactome[[j]]$tissue <- t
    tmp$pathScore_GO[[j]]$tissue <- t
    tmp$pathScore_reactome[[j]]$genes_path <- tmp$pathScore_reactome[[j]]$improvement_sign <- NA
    tmp$pathScore_GO[[j]]$genes_path <- tmp$pathScore_GO[[j]]$improvement_sign <- NA

    for(k in 1:nrow(tmp$pathScore_reactome[[j]])){
      tmp$pathScore_reactome[[j]]$genes_path[k] <- paste0(tmp$info_pathScore_reactome[[j]][[k]]$tscore$external_gene_name, collapse = ',')
      tmp$pathScore_reactome[[j]]$improvement_sign[k] <- all(tmp$info_pathScore_reactome[[j]][[k]]$tscore[,8] > tmp$pathScore_reactome[[j]][k,13])
    }

    for(k in 1:nrow(tmp$pathScore_GO[[j]])){
      tmp$pathScore_GO[[j]]$genes_path[k] <- paste0(tmp$info_pathScore_GO[[j]][[k]]$tscore$external_gene_name, collapse = ',')
      tmp$pathScore_GO[[j]]$improvement_sign[k] <- all(tmp$info_pathScore_GO[[j]][[k]]$tscore[,8] > tmp$pathScore_GO[[j]][k,15])
    }
    df_tscore[[i]][[j]] <- tmp$tscore[[j]]
    df_pathR[[i]][[j]] <- tmp$pathScore_reactome[[j]]
    df_pathGO[[i]][[j]] <- tmp$pathScore_GO[[j]]
  }
  
 
  tmp <- get(load(sprintf('predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/cluster_specific_PALAS/%s/pval_ClusterCasesVSControls_pheno_covCorr_customPath_WikiPath2019Human.RData', t)))
  df_pathWiki[[i]] <- list()

  for(j in 1:n_gr){
    tmp$pathScore[[j]]$tissue <- t
    tmp$pathScore[[j]]$genes_path <- tmp$pathScore[[j]]$improvement_sign <- NA

    for(k in 1:nrow(tmp$pathScore[[j]])){
      tmp$pathScore[[j]]$genes_path[k] <- paste0(tmp$info_pathScore[[j]][[k]]$tscore$external_gene_name, collapse = ',')
      tmp$pathScore[[j]]$improvement_sign[k] <- all(tmp$info_pathScore[[j]][[k]]$tscore[,8] > tmp$pathScore[[j]][k,13])
    }
    df_pathWiki[[i]][[j]] <- tmp$pathScore[[j]]
  }
}

df_tscore_gr <- lapply(1:n_gr, function(x) do.call(rbind, lapply(1:length(tissues_name), function(y) df_tscore[[y]][[x]])))
df_pathR_gr <- lapply(1:n_gr, function(x) do.call(rbind, lapply(1:length(tissues_name), function(y) df_pathR[[y]][[x]])))
df_pathGO_gr <- lapply(1:n_gr, function(x) do.call(rbind, lapply(1:length(tissues_name), function(y) df_pathGO[[y]][[x]])))
df_pathWiki_gr <- lapply(1:n_gr, function(x) do.call(rbind, lapply(1:length(tissues_name), function(y) df_pathWiki[[y]][[x]])))

# create a function to remove pathway with 1 gene and recompute pvalues
recompte_path <- function(tissues_name, res, id_pval){
  tmp <- lapply(tissues_name, function(x) res[res$tissue == x & res$ngenes_tscore>1,])
  for(i in 1:length(tmp)){
    tmp[[i]][, id_pval+1] <- qvalue(tmp[[i]][, id_pval])$qvalue
    tmp[[i]][, id_pval+2] <- p.adjust(tmp[[i]][, id_pval], method = 'BH')
  }
  tmp <- do.call(rbind, tmp)
  return(tmp)
}

df_pathR_gr_red <- lapply(df_pathR_gr, function(x) recompte_path(res = x, tissues_name = tissues_name, id_pval = 13))
df_pathGO_gr_red <- lapply(df_pathGO_gr, function(x) recompte_path(res = x, tissues_name = tissues_name, id_pval = 15))
df_pathWiki_gr_red <- lapply(df_pathWiki_gr, function(x) recompte_path(res = x, tissues_name = tissues_name, id_pval = 13))

### save results
out_fold <- "predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/cluster_specific_PALAS/"
for(i in 1:n_gr){
  write.table(x = df_tscore_gr[[i]], file = paste0(out_fold, 'tscore_pval_ClusterCasesVSControls_gr', i, '.txt'), col.names=T, row.names=F, sep = '\t', quote = F)
  write.table(x = df_pathR_gr_red[[i]], file = paste0(out_fold, 'path_Reactome_pval_ClusterCasesVSControls_gr', i, '_filt.txt'), col.names=T, row.names=F, sep = '\t', quote = F)
  write.table(x = df_pathGO_gr_red[[i]], file = paste0(out_fold, 'path_GO_pval_ClusterCasesVSControls_gr', i, '_filt.txt'), col.names=T, row.names=F, sep = '\t', quote = F)
  write.table(x = df_pathWiki_gr_red[[i]], file = paste0(out_fold, 'path_WikiPath2019Human_pval_ClusterCasesVSControls_gr', i, '_filt.txt'), col.names=T, row.names=F, sep = '\t', quote = F)
}

