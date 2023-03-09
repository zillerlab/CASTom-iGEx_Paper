options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggsci))
suppressPackageStartupMessages(library(ggrepel))
suppressPackageStartupMessages(library(gridExtra))
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(circlize))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(corrplot))
suppressPackageStartupMessages(library(igraph))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(ggsignif))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(ComplexHeatmap))
suppressPackageStartupMessages(library(reshape2))
options(bitmapType = 'cairo', device = 'png')


setwd('/home/luciat/eQTL_PROJECT')

fold_cl <- 'OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/'
clust_res <- get(load(sprintf('%smatchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData', fold_cl)))
outFold <- fold_cl
type_data <- 'tscore'
type_input <- 'zscaled'
type_cluster <- 'Cases'
pheno_name <- 'SCZ'
pval_corr_thr <- 0.05

pathway_feat_wiki <- get(load(sprintf('%smatchUKBB_customPath_WikiPath2019HumanOriginal_corrPCs_tscoreClusterCases_featAssociation.RData', fold_cl)))
pathway_feat_CMCset <- get(load(sprintf('%smatchUKBB_customPath_CMC_GeneSetsOriginal_corrPCs_tscoreClusterCases_featAssociation.RData', fold_cl)))
pathway_feat_tot <- get(load(sprintf('%smatchUKBB_pathOriginal_filtJS0.2_corrPCs_tscoreClusterCases_featAssociation.RData', fold_cl)))


extra_pathway_list <- data.frame(path = c("positive regulation of T cell differentiation",
                                          "Cytokines and Inflammatory Response WP530",
                                          "Complement Activation WP545",
                                          "Insulin Signaling WP481",
                                          "MO:PresynapticCompartmentProteins_Morciano",
                                          "Neuronal proteome:PSD",
                                          "MouseMeta:green_M5_Mitochondria",
                                          "CTX:green_M10_GlutamatergicSynapticFunction",
                                          "MO:Endoplasmic_Reticulum_Foster",
                                          "MO:Plasma_membrane_Foster",
                                          "Oxidative Damage WP3941",
                                          "Type II interferon signaling (IFNG) WP619"), 
                                 tissue = c("DLPC_CMC","Brain_Cerebellum", "Brain_Cerebellar_Hemisphere", 
                                            "DLPC_CMC", "DLPC_CMC", "DLPC_CMC", "DLPC_CMC", "DLPC_CMC",
                                            "DLPC_CMC", "DLPC_CMC", "Cells_EBV-transformed_lymphocytes", 
                                            "Cells_EBV-transformed_lymphocytes"))


# spider plot for a selection of pathways
get_short_name <- function(tissue_name){
  
  tmp <- sapply(strsplit(tissue_name, split = '_')[[1]], function(x) 
    substr(x = x, start = 1, stop = 1))
  if(!tissue_name %in% c('Brain_Hippocampus','Brain_Hypothalamus',
                         'Brain_Cerebellum', 'Brain_Cerebellar_Hemisphere', 
                         'DLPC_CMC')){
    out <- paste0(tmp, collapse = '')
    out <- paste0('(', out,')')
  }else{
    if('Brain_Hippocampus' == tissue_name){out <- '(BHi)'}
    if('Brain_Hypothalamus'== tissue_name){out <- '(BHy)'}
    if('Brain_Cerebellum' == tissue_name){out <- '(BCe)'}
    if('Brain_Cerebellar_Hemisphere' == tissue_name){out <- '(BCeH)'}
    if('DLPC_CMC'  == tissue_name){out <- '(DLPC)'}
  }              
  
  return(out)
}


get_pathway_scores <- function(pathway_feat, keep_pathways, res_cl) {
  
  new_id <- paste(keep_pathways$path, keep_pathways$tissue, sep = "_")
  
  keep_pathways_tissues <- lapply(pathway_feat$test_feat, function(x)
    x[paste(x$feat, x$tissue, sep = "_") %in% new_id & x$pval_corr <= 0.05, ]) %>% 
    dplyr::bind_rows() %>%
    dplyr::group_by(comp, feat) %>%
    dplyr::filter(pval == min(pval)) %>%
    dplyr::arrange(tissue, feat) %>%
    dplyr::ungroup() %>%
    dplyr::select(tissue, feat) %>%
    dplyr::distinct()
  # print(keep_pathways_tissues)
  
  # get pathway-scores
  pathscore <- list()
  for(i in 1:nrow(keep_pathways_tissues)){
    
    idx_t <- which(pathway_feat$tissues == keep_pathways_tissues$tissue[i])
    id_path <- keep_pathways_tissues$feat[i]
    tmp <- pathway_feat$scaleData[[idx_t]][, id_path, drop = F]
    colnames(tmp) <- paste(colnames(tmp), get_short_name(keep_pathways_tissues$tissue[i]))
    pathscore[[i]] <- tmp
  }            
  pathscore <- do.call(cbind, pathscore)
  
  gr_id <- sort(unique(res_cl$gr))
  df_mean <- t(sapply(gr_id, function(x) colMeans(pathscore[res_cl$gr == x, , drop=F], na.rm = T)))
  if(nrow(keep_pathways_tissues) == 1){
    df_mean <- t(df_mean)
    rownames(df_mean) <- NULL
    colnames(df_mean) <- colnames(pathscore)
  }
  df_mean <- cbind(data.frame(group = paste0('gr_',gr_id)), df_mean)
  df_mean[, -1] <- apply(df_mean[,-1, drop = F], 2, rescale)
  
  return(list(mean = df_mean, pathways = keep_pathways_tissues))
}


library(scales)
library(ggradar)


res_cl <- pathway_feat_wiki$cl                                  
input_spider_1 <- get_pathway_scores(pathway_feat_wiki, extra_pathway_list, res_cl)
input_spider_2 <- get_pathway_scores(pathway_feat_CMCset, extra_pathway_list, res_cl)
input_spider_3 <- get_pathway_scores(pathway_feat_tot, extra_pathway_list, res_cl)
input_spider <- cbind(input_spider_1$mean, input_spider_2$mean[,-1], input_spider_3$mean[,-1, drop = F])
keep_pathways_tissues <- c(input_spider_1$pathways, input_spider_2$pathways, input_spider_3$pathways)
input_spider

df_mean <- input_spider
gr_color <- pal_d3(palette = 'category20')(length(unique(res_cl$gr)))
df_mean <- df_mean[, order(df_mean[1,], decreasing = T)]
df_mean <- df_mean[, order(df_mean[2,], decreasing = T)]      
df_mean <- df_mean[, order(df_mean[3,], decreasing = T)]                              

pl <- ggradar(df_mean,  grid.min = 0, grid.max = 1, grid.mid = 0.5, 
              values.radar = c('0%', '50%', '100%'),
              group.colours = gr_color, 
              grid.label.size = 5,
              axis.label.size = 3.5, 
              group.point.size = 2,
              group.line.width = 1,
              legend.text.size= 10, 
              legend.position = 'top', 
              plot.extent.x.sf = 2, 
              plot.extent.y.sf = 1.2)
pl                    

ggsave(plot = pl, filename = sprintf('%scl%s_spiderPlotPhatway_extralist_tscoreClusterCases.pdf',  outFold, 'DLPC'), 
       device = 'pdf', width = 10, height = 10)







