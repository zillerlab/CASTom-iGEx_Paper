library(data.table)
library(Matrix)
library('SNPlocs.Hsapiens.dbSNP144.GRCh37')


setwd('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx')
tissues_name <- read.table('INPUT_DATA/Tissue_noGWAS', h=F, stringsAsFactors=F)$V1
fold <- 'OUTPUT_SCRIPTS_v2/'

# load SNP annotation
snp_ann_TWAS <- list()

for(j in 1:length(tissues_name)){
  
  t <- tissues_name[j]
  print(t)
  gene_list <- read.table(sprintf('INPUT_DATA/TWAS/GTEx_v6p/GTEx.%s.list', t), h=F, stringsAsFactors = F)
  gene_res <- read.table(sprintf('INPUT_DATA/TWAS/GTEx_v6p/GTEx.%s.profile', t), h=T, stringsAsFactors = F)
  
  df <- list()
  
  for(n in 1:length(gene_list$V1)){
    # print(n)
    id <- strsplit(gene_list$V1[n], split = sprintf('GTEx.%s/', t))[[1]][2]
    id <- strsplit(id, split = '.wgt.RDat')[[1]][1]
    load(sprintf('INPUT_DATA/TWAS/GTEx_v6p/%s', gene_list$V1[n]))
    tmp <- wgt.matrix
    tmp_snps <- snps
    top_res <- gene_res[gene_res$id == id,]
    name_method <- strsplit(names(which.max(top_res[, grepl('.r2',colnames(top_res))])), split = '.r2')[[1]][1]
    if(name_method == 'top1'){
      snp_id <- names(which.max(abs(tmp[, name_method])))
    }else{
      # print(n)
      snp_id <- names(which(tmp[, name_method] != 0))
    }
    if(length(snp_id)>0){
      df[[n]] <- data.frame(gene = id, chrom = tmp_snps$V1[match(snp_id, tmp_snps$V2)], position = tmp_snps$V4[match(snp_id, tmp_snps$V2)], ID = snp_id, stringsAsFactors = F)  
    }
  }
  
  df <- do.call(rbind, df)
  df$new_id <- paste(df$ID, df$position, df$chrom, sep = '_')
  snp_ann_TWAS[[j]] <- data.frame(chrom = df$chrom[!duplicated(df$new_id)], position = df$position[!duplicated(df$new_id)], ID = df$ID[!duplicated(df$new_id)], stringsAsFactors = F)
  snp_ann_TWAS[[j]] <- snp_ann_TWAS[[j]][order(snp_ann_TWAS[[j]]$position),]
  snp_ann_TWAS[[j]] <- snp_ann_TWAS[[j]][order(snp_ann_TWAS[[j]]$chrom),]
  snp_ann_TWAS[[j]]$V1 <- 1
  colnames(snp_ann_TWAS[[j]])[ncol(snp_ann_TWAS[[j]])] <- t
  
}  

tmp_id <- unlist(lapply(snp_ann_TWAS, function(x)  paste(x$ID, x$position, x$chrom, sep = '_')))
df_tot <- data.frame(id = tmp_id[!duplicated(tmp_id)],
                     chrom = unlist(lapply(snp_ann_TWAS, function(x) x$chrom))[!duplicated(tmp_id)], 
                     position= unlist(lapply(snp_ann_TWAS, function(x) x$position))[!duplicated(tmp_id)], 
                     ID = unlist(lapply(snp_ann_TWAS, function(x) x$ID))[!duplicated(tmp_id)], stringsAsFactors = F)
df_tot <- cbind(df_tot, matrix(0, ncol = length(tissues_name), nrow = nrow(df_tot)))
colnames(df_tot)[-c(1:4)] <- tissues_name

for(j in 1:length(tissues_name)){
  snp_ann_TWAS[[j]]$new_id <- paste(snp_ann_TWAS[[j]]$ID, snp_ann_TWAS[[j]]$position, snp_ann_TWAS[[j]]$chrom, sep = '_')
  df_tot[df_tot$id %in% snp_ann_TWAS[[j]]$new_id, tissues_name[j]] <- 1  
}
df_tot <- df_tot[, -1]
# reorder
df_tot <- df_tot[order(df_tot$position),]
df_tot <- df_tot[order(df_tot$chrom),]
df_tot$chrom <- paste0('chr', df_tot$chrom)

write.table('OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/TWAS_regSNPs_annotation.txt', x = df_tot, col.names = T, row.names = F, sep = '\t', quote = F)

###################################################################
snp_ann_prediXcan <- list()
library('RSQLite')

sqlite.driver <- dbDriver("SQLite")
snps_annotation <- SNPlocs.Hsapiens.dbSNP144.GRCh37

for(j in 1:length(tissues_name)){
  
  t <- tissues_name[j]
  print(t)
  
  db <- dbConnect(sqlite.driver, dbname = sprintf('INPUT_DATA/prediXcan/GTEx_v6p//TW_%s/TW_%s_0.5.db',t, t))  
  weights <- dbReadTable(db,'weights')
  
  snp_id <- unique(weights$rsid)
  tmp_pos <- snpsById(x = snps_annotation, ids = snp_id, ifnotfound="drop")
  snp_ann_prediXcan[[j]] <- data.frame(chrom = as.numeric(as.character(as.data.frame(seqnames(tmp_pos))$value)), position = pos(tmp_pos), ID = mcols(tmp_pos)@listData$RefSNP_id, stringsAsFactors = F)
  snp_ann_prediXcan[[j]] <- snp_ann_prediXcan[[j]][order(snp_ann_prediXcan[[j]]$position),]
  snp_ann_prediXcan[[j]] <- snp_ann_prediXcan[[j]][order(snp_ann_prediXcan[[j]]$chrom),]
  snp_ann_prediXcan[[j]]$V1 <- 1
  colnames(snp_ann_prediXcan[[j]])[ncol(snp_ann_prediXcan[[j]])] <- t
  
}

tmp_id <- unlist(lapply(snp_ann_prediXcan, function(x)  paste(x$ID, x$position, x$chrom, sep = '_')))
df_tot <- data.frame(id = tmp_id[!duplicated(tmp_id)],
                     chrom = unlist(lapply(snp_ann_prediXcan, function(x) x$chrom))[!duplicated(tmp_id)], 
                     position= unlist(lapply(snp_ann_prediXcan, function(x) x$position))[!duplicated(tmp_id)], 
                     ID = unlist(lapply(snp_ann_prediXcan, function(x) x$ID))[!duplicated(tmp_id)], stringsAsFactors = F)
df_tot <- cbind(df_tot, matrix(0, ncol = length(tissues_name), nrow = nrow(df_tot)))
colnames(df_tot)[-c(1:4)] <- tissues_name

for(j in 1:length(tissues_name)){
  snp_ann_prediXcan[[j]]$new_id <- paste(snp_ann_prediXcan[[j]]$ID, snp_ann_prediXcan[[j]]$position, snp_ann_prediXcan[[j]]$chrom, sep = '_')
  df_tot[df_tot$id %in% snp_ann_prediXcan[[j]]$new_id, tissues_name[j]] <- 1  
}
df_tot <- df_tot[, -1]
df_tot <- df_tot[order(df_tot$position),]
df_tot <- df_tot[order(df_tot$chrom),]
df_tot$chrom <- paste0('chr', df_tot$chrom)

write.table('OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/prediXcan_regSNPs_annotation.txt', x = df_tot, col.names = T, row.names = F, sep = '\t', quote = F)


