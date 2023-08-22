options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(qvalue))
suppressPackageStartupMessages(library(igraph))
suppressPackageStartupMessages(library(pryr))
suppressPackageStartupMessages(library(Matrix))
suppressPackageStartupMessages(library(coin))
suppressPackageStartupMessages(library(umap))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(ggsci))
suppressPackageStartupMessages(library(pheatmap))
suppressPackageStartupMessages(library(RColorBrewer))
library(corrplot)
options(bitmapType = 'cairo', device = 'png')

setwd("~/eQTL_PROJECT/")
fold <- 'OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_'
clust_res <- get(load(sprintf('%stscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData', fold)))
type_data <- 'tscore'
type_input <- 'zscaled'
type_sim <- 'HK'
type_cluster <- 'Cases'

sampleAnn <- clust_res$sampleInfo[, grepl('C',colnames(clust_res$sampleInfo))]
PCs_name <- colnames(sampleAnn)
df <- clust_res$cl_best
P <- length(unique(df$gr))
gr_color <- pal_d3(palette = 'category20')(P)

# plot distribution PCs
df_cov <- cbind(sampleAnn, data.frame(gr = df$gr, cohort = clust_res$sampleInfo$cohort))
df_cov$gr <- paste0('gr', df_cov$gr)
df_cov$gr <- factor(df_cov$gr, levels = paste0('gr', 1:P))
df_cov$cohort <- factor(df_cov$cohort)
df_cov_PC <- data.frame(val = as.vector(as.matrix(df_cov[, PCs_name])), 
                        PC = unlist(lapply(PCs_name, function(x) rep(x, nrow(df_cov)))),
                        gr = rep(df_cov$gr, length(PCs_name)))
df_cov_PC$PC <- factor(df_cov_PC$PC, levels = PCs_name)

p <- ggboxplot(df_cov_PC, x = "gr", y = "val", fill = "gr", color = 'black', legend = 'none', outlier.size = 0.2, alpha = 0.8) + stat_compare_means(label = "p.format", size = 3) 
p <- ggpar(p, palette = gr_color, xlab = '', ylab = '', x.text.angle = 45)
p <- facet(p, facet.by = "PC", short.panel.labs = T, scales = 'free_y', nrow = 1)

ggsave(filename = sprintf('%s%s_corrPCs_%s_cluster%s_PGmethod_%smetric_PCs.pdf', 
                          fold, type_data, type_input, type_cluster, type_sim), 
       width = 13, height = 4, plot = p, device = 'pdf')

# plot cohort
tmp <- table(df_cov$cohort, df_cov$gr)
df_cohorts <- sweep(tmp, 2, colSums(tmp), "/")
pdf(sprintf('%s%s_corrPCs_%s_cluster%s_PGmethod_%smetric_cohorts.pdf', 
            fold, type_data, type_input, type_cluster, type_sim), width = 8, height = 4)
corrplot(t(df_cohorts), is.corr = FALSE,  method = 'color', addgrid.col = 'white',  
         cl.pos = 'b', tl.col = 'black', cl.cex = 0.9,
         addCoef.col = 'black',  number.cex= 0.5)                                                   
dev.off()


##############################
## filt version
#fold <- 'OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_filt0.1_'
#clust_res <- get(load(sprintf('%stscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData', fold)))
#type_data <- 'tscore'
#type_input <- 'zscaled'
#type_sim <- 'HK'
#type_cluster <- 'Cases'
#
#sampleAnn <- clust_res$sampleInfo[, grepl('C',colnames(clust_res$sampleInfo))]
#PCs_name <- colnames(sampleAnn)
#df <- clust_res$cl_best
#P <- length(unique(df$gr))
#gr_color <- pal_d3(palette = 'category20')(P)
#
## plot distribution PCs
#df_cov <- cbind(sampleAnn, data.frame(gr = df$gr, cohort = clust_res$sampleInfo$cohort))
#df_cov$gr <- paste0('gr', df_cov$gr)
#df_cov$gr <- factor(df_cov$gr, levels = paste0('gr', 1:P))
#df_cov$cohort <- factor(df_cov$cohort)
#df_cov_PC <- data.frame(val = as.vector(as.matrix(df_cov[, PCs_name])), 
#                        PC = unlist(lapply(PCs_name, function(x) rep(x, nrow(df_cov)))),
#                        gr = rep(df_cov$gr, length(PCs_name)))
#df_cov_PC$PC <- factor(df_cov_PC$PC, levels = PCs_name)
#
#p <- ggboxplot(df_cov_PC, x = "gr", y = "val", fill = "gr", color = 'black', legend = 'none', outlier.size = 0.2, alpha = 0.8) + stat_compare_means(label = "p.format", size = 3) 
#p <- ggpar(p, palette = gr_color, xlab = '', ylab = '', x.text.angle = 45)
#p <- facet(p, facet.by = "PC", short.panel.labs = T, scales = 'free_y', nrow = 1)
#
#ggsave(filename = sprintf('%s%s_corrPCs_%s_cluster%s_PGmethod_%smetric_PCs.pdf', 
#                          fold, type_data, type_input, type_cluster, type_sim), 
#       width = 14, height = 4, plot = p, device = 'pdf')
#
## plot cohort
#tmp <- table(df_cov$cohort, df_cov$gr)
#df_cohorts <- sweep(tmp, 2, colSums(tmp), "/")
#pdf(sprintf('%s%s_corrPCs_%s_cluster%s_PGmethod_%smetric_cohorts.pdf', 
#            fold, type_data, type_input, type_cluster, type_sim), width = 8, height = 4)
#corrplot(t(df_cohorts), is.corr = FALSE,  method = 'color', addgrid.col = 'white',  
#         cl.pos = 'b', tl.col = 'black', cl.cex = 0.9,
#         addCoef.col = 'black',  number.cex= 0.5)                                                   
#dev.off()



