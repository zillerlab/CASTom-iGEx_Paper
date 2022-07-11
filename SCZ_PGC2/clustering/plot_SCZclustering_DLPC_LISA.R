# plot SCZ clustering
# plot on LISA cluster: cannot move data
# script working with R/4.0.2

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(ggsci))
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(ComplexHeatmap))
suppressPackageStartupMessages(library(circlize))
suppressPackageStartupMessages(library(PGSEA))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(corrplot))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tibble))
suppressPackageStartupMessages(library(ggradar))
suppressPackageStartupMessages(library(scales))
options(bitmapType = 'cairo', device = 'png')


#####################################################################################################################
functR <- '/home/luciat/castom-igex/Software/model_clustering/clustering_functions.R'
type_cluster <- 'Cases'
pval_feat <- 0.01
type_cluster_data <- 'tscore'
tissue_name <- 'DLPC_CMC'
pheno_name <- 'SCZ'
fold_cl = '/home/luciat/eQTL_PROJECT/OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_'
fold = '/home/luciat/eQTL_PROJECT/OUTPUT_all/clustering_res_matchUKBB_corrPCs/DLPC_CMC/matchUKBB_'
fold_out <- '/home/luciat/eQTL_PROJECT/OUTPUT_all/clustering_res_matchUKBB_corrPCs/DLPC_CMC/plots/matchUKBB_'
geneInfoFile <- '/home/luciat/eQTL_PROJECT/OUTPUT_CMC/train_CMC/200kb/resPrior_regEval_allchr.txt'
clustFile <- sprintf('%stscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData', fold_cl)
tscore_featRelFile <- sprintf('%stscoreOriginal_corrPCs_tscoreClusterCases_featAssociation.RData', fold_cl)
genes_to_filter <- '/home/luciat/eQTL_PROJECT/compare_prediction_UKBB_SCZ-PGC/DLPC_CMC_filter_genes_matched_datasets.txt'
#####################################################################################################################

source(functR)

# get clustering structure
res_cl <- get(load(clustFile))
cl <- res_cl$cl_best
print(identical(res_cl$sampleInfo$Individual_ID, cl$id))
# cl$cohort <- res_cl$sampleInfo$cohort
print(paste('number of genes used for clustering:', ncol(res_cl$input_data)))


############################################
######## block T-score MHC locus ###########
############################################

tmp <- get(load(tscore_featRelFile))
tscore_input <- tmp$scaleData
tscore_input <- tscore_input[[1]] # DLPC
tscore_feat <- tmp$test_feat[[1]]
res_pval <- tmp$res_pval[[1]]
print(identical(rownames(tscore_input), cl$id))

keep_gene <- unique(tscore_feat$feat[tscore_feat$pval_corr <= pval_feat])
geneInfo <- read.table(geneInfoFile, h=T, stringsAsFactors = F, sep ='\t')
geneInfo <- geneInfo[geneInfo$dev_geno > 0.01 & geneInfo$test_dev_geno > 0, ]
tscore_info <- geneInfo
# remove duplicates (already done for input data)
id_dup <- geneInfo$external_gene_name[duplicated(geneInfo$external_gene_name)]
if(length(id_dup)>0){
  geneInfo <- geneInfo[!geneInfo$external_gene_name %in% id_dup, ]
}
geneInfo_keep <- geneInfo[match(keep_gene, geneInfo$external_gene_name),]
geneInfo_keep$Zstat <- res_pval[match(keep_gene,res_pval$external_gene_name),7]
geneInfo_sign <- geneInfo_keep
# restric to MHC locus
HLA_reg <- c(26000000, 34000000)
geneInfo_keep <- geneInfo_keep[(geneInfo_keep$chrom %in% 'chr6' & geneInfo_keep$end_position <=HLA_reg[2] & geneInfo_keep$start_position >= HLA_reg[1]) , ]
test_feat_tscore <- tscore_feat

if(!is.null(genes_to_filter)){
  genes_filt <- read.table(genes_to_filter, h=T, stringsAsFactors = F, sep = '\t')
  genes_filt <- genes_filt[genes_filt$keep & !is.na(genes_filt$keep),]
  geneInfo_keep <- geneInfo_keep[geneInfo_keep$ensembl_gene_id %in% genes_filt$ensembl_gene_id,]
}

# filter based on correlation (0.7)
# chr <- sort(as.numeric(unique(sapply(geneInfo_keep$chrom, function(x) strsplit(x, split  = 'chr')[[1]][2]))))
chr <- 6
thr_corr <- 0.7
cor_mat <- cor(tscore_input[, match(geneInfo_keep$external_gene_name, colnames(tscore_input)), drop = F])
tmp_gene <- geneInfo_keep[geneInfo_keep$chrom == paste0('chr', chr),]

while(any(abs(cor_mat[upper.tri(cor_mat)]) > thr_corr)){
  
  locus_list <- apply(cor_mat, 1, function(x) abs(x) > thr_corr)
  len_gene <- c()
  keep_gene <- c()
  for(j in 1:nrow(locus_list)){
    tmp_sel <-  tmp_gene[locus_list[j,],]
    tmp_sel <- tmp_sel[!tmp_sel$external_gene_name %in% len_gene, ]
    len_gene <- unique(c(len_gene, tmp_sel$external_gene_name))
    keep_gene <- unique(c(keep_gene, tmp_sel$external_gene_name[which.max(abs(tmp_sel$Zstat))]))
  }
  
  tmp_gene <- tmp_gene[tmp_gene$external_gene_name %in% keep_gene, ]
  cor_mat <- cor(tscore_input[, match(tmp_gene$external_gene_name, colnames(tscore_input)), drop = F])
}
geneInfo_keep <- tmp_gene
geneInfo_keep <- geneInfo_keep[order(as.numeric(
  sapply(geneInfo_keep$chrom, function(x) strsplit(x, split = 'chr')[[1]][2])), 
  geneInfo_keep$start_position), ]

### plot ###
print(paste('plot Fig. 3A n.genes =', nrow(geneInfo_keep)))
# "plot Fig. 3A n.genes = 58"
pheat_pl_tscore(mat_tscore = tscore_input, cl = cl, info_feat_tscore = geneInfo_keep, 
                test_feat_tscore = test_feat_tscore, width_pl = 8 + round(length(unique(cl$gr))*0.25), 
                height_pl = round(3 + nrow(geneInfo_keep)*0.1), outFile = sprintf('%sMHC_tscoreOriginal_%sCluster%s', fold_out,type_cluster_data,type_cluster), 
                cap = 3, res_pl = 250)

#### plot correlation
cor_mat <- cor(tscore_input[, match(geneInfo_keep$external_gene_name, colnames(tscore_input)), drop = F])
diag(cor_mat) <- 0
new_name <- colnames(cor_mat)
rownames(cor_mat) <- new_name
# save
save(cor_mat, file = sprintf('%sMHC_tscoreOriginal_%sCluster%s_corrGenes.RData',fold_out,type_cluster_data,type_cluster))


col <- rev(colorRampPalette(brewer.pal(9, 'PuOr'))(101))
# col[51] <- 'black'
val <- round(max(abs(cor_mat), na.rm = T), digits = 2) + 0.01
# ord <- corrMatOrder(cor_mat, order="hclust", hclust.method = 'ward.D')

pdf(file = sprintf('%sMHC_tscoreOriginal_%sCluster%s_corrGenes.pdf',fold_out,type_cluster_data,type_cluster), width = 8, height = 8, compress = F)
corrplot(cor_mat, type="upper", order = 'original', 
         cl.lim = c(-val,val),  
         col=col,
         method = 'color', tl.srt=90, cl.align.text='c', tl.col = "black", tl.cex = 0.8, 
         na.label = '->', na.label.col = 'black', is.corr = F, number.cex=0.8, mar = c(0,0,5,0))
dev.off()


###################################
#### spider plot with controls ####
###################################
## phenotypes ## 
keep_mets <- c('Body mass index (BMI)', 'Hip circumference', 'Weight',
               'Diastolic blood pressure, automated reading',
               'Triglycerides', 'HDL cholesterol', 'Glycated haemoglobin (HbA1c)', 
               'Glucose')
phenoInfo <- read.delim('/home/luciat/UKBB_SCZrelated/phenotypeDescription_rsSCZ_updated.txt', h=T, stringsAsFactors = F, sep = '\t')
phenoInfo <- phenoInfo[!grepl('Cognitive function online > Fluid intelligence',phenoInfo$Path),]
phenoInfo <- phenoInfo[!grepl('Cognitive function online > Pairs matching',phenoInfo$Path),]
keep_cogn <- c('FI1 : numeric addition test','FI2 : identify largest number', 
               'FI3 : word interpolation', 'FI4 : positional arithmetic', 
               'FI7 : synonym', 'FI6 : conditional arithmetic',
               'FI8 : chained arithmetic', 
               'FI9 : concept interpolation', 
               'FI10 : arithmetic sequence recognition', 
               'FI12 : square sequence recognition', 
               'FI13 : subset inclusion logic', 
               'Fluid intelligence score', 
               'Mean time to correctly identify matches', 
               'Maximum digits remembered correctly',
               'Duration to complete alphanumeric path (trail #2)',
               'Duration to entering value',
               'Prospective memory result', 
               'Time to complete round')
# load risk scores on all samples, (combine all cohorts)
common_path <- '/home/luciat/eQTL_PROJECT/OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/'
rs_tot <- read.table(gzfile(sprintf('%s/matchUKBB_allSamples_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz', common_path)), 
                h=T, stringsAsFactors = F, sep = '\t', check.names = F)
rs_MetS <- rs_tot[, phenoInfo$pheno_id[phenoInfo$Field %in% keep_mets]]
rs_cognFun <- rs_tot[, phenoInfo$pheno_id[match(keep_cogn, phenoInfo$Field)]]
rownames(rs_MetS) <- rownames(rs_cognFun) <- rs_tot$Individual_ID

samples_tot <- data.frame(id = as.vector(rs_tot$Individual_ID))
samples_tot <- samples_tot[!samples_tot$id %in% res_cl$sampleOutliers$sample$Individual_ID, ,drop=F]
samples_tot$cl <- 'Controls'
samples_tot$cl[match(cl$id, samples_tot$id)] <- paste0('Cases_gr', cl$gr)
rs_MetS <- rs_MetS[match(samples_tot$id,rownames(rs_MetS)),]
rs_cognFun <- rs_cognFun[match(samples_tot$id,rownames(rs_cognFun)),]

colnames(rs_MetS) <- phenoInfo$Field[match(colnames(rs_MetS), phenoInfo$pheno_id)]
colnames(rs_cognFun) <- phenoInfo$Field[match(colnames(rs_cognFun), phenoInfo$pheno_id)]
cl_names <- c('Controls', paste0('Cases_gr', sort(unique(cl$gr))))

# compute mean across groups
P <- length(unique(cl$gr))
gr_color <- pal_d3(palette = 'category20')(P)
mean_MetS <- t(sapply(cl_names, function(x) colMeans(rs_MetS[samples_tot$cl == x,], na.rm = T)))
mean_MetS <- cbind(data.frame(group = cl_names), mean_MetS)
mean_MetS[, -1] <- apply(mean_MetS[,-1], 2, rescale)
pl1 <- ggradar(mean_MetS,  grid.min = 0, grid.max = 1, grid.mid = 0.5, 
               values.radar =c('0%', 
                               '50%', 
                               '100%'),
               group.colours =  c( gr_color, 'grey60'), 
               grid.label.size = 5,
               axis.label.size = 3.5, 
               group.point.size = 2,
               group.line.width = 1,
               legend.text.size= 10, 
               legend.position = 'top', 
               plot.extent.x.sf = 2, 
               plot.extent.y.sf = 1.2)
# pl + theme(plot.margin = margin(2, 4, 4, 4, "cm"))

ggsave(plot = pl1, filename = sprintf('%sspiderPlotPheno_tscoreClusterCases_p1.pdf',  fold_out), device = 'pdf', width = 10, height = 10)


mean_cognFunc <- t(sapply(cl_names, function(x) colMeans(rs_cognFun[samples_tot$cl == x,], na.rm = T)))
mean_cognFunc <- cbind(data.frame(group = cl_names), mean_cognFunc)
mean_cognFunc[, -1] <- apply(mean_cognFunc[,-1], 2, rescale)
pl2 <- ggradar(mean_cognFunc,  grid.min = 0, grid.max = 1, grid.mid = 0.5, 
               values.radar =c('0%', 
                               '50%', 
                               '100%'),
               group.colours =  c( gr_color, 'grey60'), 
               grid.label.size = 5,
               axis.label.size = 3.5, 
               group.point.size = 2,
               group.line.width = 1,
               legend.text.size= 10, 
               legend.position = 'top', 
               plot.extent.x.sf = 2, 
               plot.extent.y.sf = 1.2)
# pl + theme(plot.margin = margin(2, 4, 4, 4, "cm"))

ggsave(plot = pl2, filename = sprintf('%sspiderPlotPheno_tscoreClusterCases_p2.pdf',  fold_out), device = 'pdf', width = 10, height = 10)


