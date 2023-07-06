# create final file with regSNP id
library(data.table)
library(Matrix)

setwd('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx')

tissues_name <- read.table('INPUT_DATA/Tissue_noGWAS', h=F, stringsAsFactors=F)$V1
fold <- 'OUTPUT_SCRIPTS_v2/'
fold_comp <- '/psycl/g/mpsziller/lucia/PriLer_TRAIN_PLOTS/res_GTEx/'

# load SNP annotation
snp_ann <- list()
snp_ann_noprior <- list()
snp_ann_her <- list()
snp_ann_her_noprior <- list()
snp_ann_rel <- list()
snp_ann_rel_noprior <- list()
snp_ann_TWAScomp <- list()
snp_ann_prediXcancomp <- list()

for(i in 1:22){
  print(i)
  
  tmp <- fread(sprintf('%shg19_SNPs_chr%i_matched.txt', fold, i), h=T, stringsAsFactors = F, data.table = F)
  colnames(tmp)[colnames(tmp) == 'ID_CMC'] <- 'ID_GTEx'
  snp_ann[[i]] <- matrix(0, nrow = nrow(tmp), ncol = length(tissues_name)+ncol(tmp))
  colnames(snp_ann[[i]]) <- c(colnames(tmp), tissues_name)
  snp_ann[[i]] <- as.data.frame(snp_ann[[i]])
  snp_ann[[i]][,1:ncol(tmp)] <- tmp
  snp_ann_noprior[[i]] <- snp_ann_her[[i]] <- snp_ann_her_noprior[[i]] <- snp_ann_rel[[i]] <- snp_ann_rel_noprior[[i]] <-  snp_ann[[i]]
  snp_ann_prediXcancomp[[i]] <- snp_ann_TWAScomp[[i]] <-  snp_ann[[i]]
  
}

for(j in 1:length(tissues_name)){
  
  print(j)
  geneInfo <- fread(sprintf('OUTPUT_SCRIPTS_v2/%s/200kb/noGWAS/resPrior_regEval_allchr.txt', tissues_name[j]),h=T, stringsAsFactors = F, data.table = F)
  gene_comp_TWAS <- fread(sprintf('%s%s_compare_PriLer_TWAS_v6p.txt', fold_comp, tissues_name[j]),h=T, stringsAsFactors = F, data.table = F)
  gene_comp_prediXcan <- fread(sprintf('%s%s_compare_PriLer_prediXcan_v6p.txt', fold_comp, tissues_name[j]),h=T, stringsAsFactors = F, data.table = F)
  
  tmp <- get(load(sprintf('OUTPUT_SCRIPTS_v2/%s/200kb/noGWAS/resPrior_regCoeffSnps_allchr.RData', tissues_name[j])))
  
  for(i in 1:22){ 
    
    tmp_geneInfo <- geneInfo[geneInfo$chr == paste0('chr', i),]
    snp_ann[[i]][Matrix::rowSums(tmp[[i]] != 0) > 0, tissues_name[j]] <- 1
    snp_ann_her[[i]][Matrix::rowSums(tmp[[i]][, tmp_geneInfo$type == 'heritable'] != 0) > 0, tissues_name[j]] <- 1
    snp_ann_rel[[i]][Matrix::rowSums(tmp[[i]][,tmp_geneInfo$test_dev_geno > 0 & tmp_geneInfo$dev_geno > 0.01] != 0) > 0, tissues_name[j]] <- 1
    
    tmp_geneInfo$id_TWAS <- F
    tmp_geneInfo$id_TWAS[tmp_geneInfo$ensembl_gene_id %in% gene_comp_TWAS$ensembl_gene_id] <- T
    tmp_geneInfo$id_prediXcan <- F
    tmp_geneInfo$id_prediXcan[tmp_geneInfo$ensembl_gene_id %in% gene_comp_prediXcan$ensembl_gene_id] <- T
    snp_ann_TWAScomp[[i]][Matrix::rowSums(tmp[[i]][, tmp_geneInfo$id_TWAS] != 0) > 0, tissues_name[j]] <- 1
    snp_ann_prediXcancomp[[i]][Matrix::rowSums(tmp[[i]][, tmp_geneInfo$id_prediXcan] != 0) > 0, tissues_name[j]] <- 1
    
  }
  
  geneInfo <- fread(sprintf('OUTPUT_SCRIPTS_v2/%s/200kb/noGWAS/resNoPrior_regEval_allchr.txt', tissues_name[j]),h=T, stringsAsFactors = F, data.table = F)
  tmp <- get(load(sprintf('OUTPUT_SCRIPTS_v2/%s/200kb/noGWAS/resNoPrior_regCoeffSnps_allchr.RData', tissues_name[j])))
  for(i in 1:22){  
    tmp_geneInfo <- geneInfo[geneInfo$chr == paste0('chr', i),]
    snp_ann_noprior[[i]][Matrix::rowSums(tmp[[i]] != 0) > 0, tissues_name[j]] <- 1
    snp_ann_her_noprior[[i]][Matrix::rowSums(tmp[[i]][, tmp_geneInfo$type == 'heritable'] != 0) > 0, tissues_name[j]] <- 1
    snp_ann_rel_noprior[[i]][Matrix::rowSums(tmp[[i]][,tmp_geneInfo$test_dev_geno > 0 & tmp_geneInfo$dev_geno > 0.01] != 0) > 0, tissues_name[j]] <- 1
  }
  
}

# save results
snp_ann_noprior <- do.call(rbind, snp_ann_noprior)
snp_ann <- do.call(rbind, snp_ann)
write.table('OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resPrior_regSNPs_annotation.txt', x = snp_ann, col.names = T, row.names = F, sep = '\t', quote = F)
write.table('OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resNoPrior_regSNPs_annotation.txt', x = snp_ann_noprior, col.names = T, row.names = F, sep = '\t', quote = F)

snp_ann_rel_noprior <- do.call(rbind, snp_ann_rel_noprior)
snp_ann_rel <- do.call(rbind, snp_ann_rel)
write.table('OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resPrior_regSNPs_reliableGenes_annotation.txt', x = snp_ann_rel, col.names = T, row.names = F, sep = '\t', quote = F)
write.table('OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resNoPrior_regSNPs_reliableGenes_annotation.txt', x = snp_ann_rel_noprior, col.names = T, row.names = F, sep = '\t', quote = F)

snp_ann_her_noprior <- do.call(rbind, snp_ann_her_noprior)
snp_ann_her <- do.call(rbind, snp_ann_her)
write.table('OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resPrior_regSNPs_heritableGenes_annotation.txt', x = snp_ann_her, col.names = T, row.names = F, sep = '\t', quote = F)
write.table('OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resNoPrior_regSNPs_heritableGenes_annotation.txt', x = snp_ann_her_noprior, col.names = T, row.names = F, sep = '\t', quote = F)

snp_ann_TWAScomp <- do.call(rbind, snp_ann_TWAScomp)
snp_ann_prediXcancomp <- do.call(rbind, snp_ann_prediXcancomp)
write.table('OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resPrior_regSNPs_TWASgenes_annotation.txt', x = snp_ann_TWAScomp, col.names = T, row.names = F, sep = '\t', quote = F)
write.table('OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resPrior_regSNPs_prediXcangenes_annotation.txt', x = snp_ann_prediXcancomp, col.names = T, row.names = F, sep = '\t', quote = F)


