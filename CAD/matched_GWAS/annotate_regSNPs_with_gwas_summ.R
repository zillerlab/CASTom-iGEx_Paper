# combine all tissues results (CAD)
library(qvalue)
library(data.table)
library(rlist)
library(dplyr)
library(Matrix)


setwd('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/')
tissues_name <- c('Adipose_Subcutaneous', 'Adipose_Visceral_Omentum', 
                  'Adrenal_Gland', 'Artery_Aorta', 'Artery_Coronary', 
                  'Colon_Sigmoid', 'Colon_Transverse', 
                  'Heart_Atrial_Appendage','Heart_Left_Ventricle', 
                  'Liver', 'Whole_Blood')
# bp_loci <- 1000000
# cis_size <- 200000

####################
# for each gene in a tissue, assign SNPs regulating, beta regression coefficients and GWAS output

## load GWAS
gwas_matched <- fread('OUTPUT_GWAS/CAD_UKBB_logistic_gwas_summary.txt', h=T, 
                      stringsAsFactors=F, data.table = F)
gwas_matched$CHROM <- factor(gwas_matched$CHROM, levels = 1:22)

gwas_matched <- gwas_matched %>% 
                group_by(CHROM) %>%
                mutate(idx_regCoeff = row_number())


gene_total <- fread('OUTPUT_GTEx/predict_CAD/AllTissues/200kb/CAD_GWAS_bin5e-2/UKBB/tscore_pval_CAD_HARD_covCorr.txt', 
                     sep = '\t', stringsAsFactors = F, data.table = F)

reg_snps_gwas <- list()
for(t in tissues_name){
  
  print(t)  
  id_t <- which(tissues_name == t)
  gene_tissue <- gene_total %>% filter(tissue == t)
  
  priler_info <- fread(sprintf('OUTPUT_GTEx/train_GTEx/%s/200kb/CAD_GWAS_bin5e-2/resPrior_regEval_allchr.txt', t), data.table = F, stringsAsFactors = F, h=T)
  regBeta <- get(load(sprintf('OUTPUT_GTEx/train_GTEx/%s/200kb/CAD_GWAS_bin5e-2/resPrior_regCoeffSnps_allchr.RData', t)))
  
  # add id to match beta coeff file
  priler_info$chrom <- factor(priler_info$chrom, levels = paste0('chr', 1:22))
  priler_info <- priler_info %>% 
                 group_by(chrom) %>%
                 mutate(idx_regCoeff = row_number())  %>% # add index for each chromosome
                 semi_join( y= gene_tissue, by = 'ensembl_gene_id') # consider only reliable genes
  
  out_t <- list()
  for(g in gene_tissue$ensembl_gene_id){
    
    id_out <- which(gene_tissue$ensembl_gene_id == g)
    print(id_out)  
    
    info_tmp <- priler_info %>% filter(ensembl_gene_id == g)
    
    chr_id <- strsplit(as.character(info_tmp$chrom), split = 'chr')[[1]][2]
    chr_id <- as.numeric(chr_id)
    gene_id <- info_tmp$idx_regCoeff
    
    beta_snps_gene <- regBeta[[chr_id]][, gene_id]
    snp_id <- which(beta_snps_gene!=0)
   
    gwas_tmp <- gwas_matched %>% 
                filter(CHROM == chr_id, idx_regCoeff %in% snp_id) %>%
                select(-c('A1', 'TEST', 'OBS_CT')) %>%
                mutate(regCoeff = beta_snps_gene[snp_id]) %>%
                mutate(ensembl_gene_id = g, external_gene_name = info_tmp$external_gene_name) %>%
                mutate(tissue = t)
    
     out_t[[id_out]] <- gwas_tmp 
  }  
  
  reg_snps_gwas[[id_t]] <- do.call(rbind, out_t)
  
  # save single tissue
  fold <- sprintf('OUTPUT_GTEx/predict_CAD/%s/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/matched_GWAS_comparison/', t)
  write.table(x = as.data.frame(reg_snps_gwas[[id_t]]),
              file = sprintf('%s/regSnps_annotated_CAD_UKBB_gwas.txt', fold), 
              col.names = T, row.names = F, sep = '\t', quote = F)
  
}

reg_snps_gwas_total <- do.call(rbind, reg_snps_gwas)

# save
fold <- 'OUTPUT_GTEx/predict_CAD/AllTissues/200kb/CAD_GWAS_bin5e-2/UKBB/matched_GWAS_comparison/'
write.table(x = as.data.frame(reg_snps_gwas_total),
            file = sprintf('%s/regSnps_annotated_CAD_UKBB_gwas.txt', fold), 
            col.names = T, row.names = F, sep = '\t', quote = F)


