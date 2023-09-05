# convert pathway scores to phenotype format
# add a summary file to convert pheno_id to included genes and transcripts in the computation
# associate with group and correct for PCs

library(data.table)
library(PGSEA)


setwd("/psycl/g/mpsziller/lucia/CAD_SHIP")
gene_exp_file <- "GENE_EXPR/Filtered_SHIP-TREND_GX_plate01-14_QuantileNormalized.log2Transformd-zz_transposed-resid-SHIP_2022_27.txt"
pathGO_file <- "GENE_EXPR/Pathway_GO_scores.txt"
pathR_file <- "GENE_EXPR/Pathway_Reactome_scores.txt"
reactome_file <- "/psycl/g/mpsziller/lucia/castom-igex/refData/ReactomePathways.gmt"
GO_file <- "/psycl/g/mpsziller/lucia/castom-igex/refData/GOterm_geneAnnotation_allOntologies.RData"


gene_exp <- fread(gene_exp_file, header = T, stringsAsFactors = F, sep = '\t', check.names = F, data.table = F)
gene_ann <- gene_exp[, 1:4]
gene_exp <- gene_exp[,-(1:4)]
gene_exp <- t(gene_exp) # samples on the rows
colnames(gene_exp) <- gene_ann$external_gene_name

pathGO <- fread(pathGO_file, header = T, stringsAsFactors = F, sep = '\t', check.names = F, data.table = F)
pathR <- fread(pathR_file, header = T, stringsAsFactors = F, sep = '\t', check.names = F, data.table = F)

# Reactome
gs <- readGmt(reactome_file)

gs=lapply(gs,function(X){
  X@ids=gsub(",1.0","",X@ids)
  return(X)
})
gs_name <- sapply(gs, function(x) x@reference)
gs <- gs[which(gs_name %in% pathR$pathID)]
gs_name <- unname(sapply(gs, function(x) x@reference))
identical(pathR$pathID, gs_name)

genes_path <- lapply(gs, function(x) gene_ann$external_gene_name[gene_ann$external_gene_name %in% x@ids])
ngenes_path <-  sapply(gs, function(x) length(unique(x@ids[x@ids != ""])))
ngenes_tscore_path <- sapply(genes_path, length)

# remove pathway with the same genes, recompute qvalue
rm_path <- c()
len <- c()
for(i in 1:length(genes_path)){
  # print(i)
  id <- which(sapply(genes_path, function(x) all(genes_path[[i]] %in% x) & all(x %in% genes_path[[i]])))
  len[i] <- length(id)
  ngenes_tmp <- ngenes_path[id]
  # take the one woth the lower amount of genes
  rm_path <- c(rm_path, gs_name[id][-which.min(ngenes_tmp)])
}

rm_path <- unique(rm_path)
id_rm <- which(pathR$pathID %in% rm_path)
if(length(id_rm)>0){
  pathR <- pathR[-id_rm, ]
  gs <- gs[-id_rm]
  gs_name <- unname(sapply(gs, function(x) x@reference))
  print(identical(gs_name, pathR$pathID))
  genes_path <- lapply(gs, function(x) gene_ann$external_gene_name[gene_ann$external_gene_name %in% x@ids])
  ngenes_path <- ngenes_path[-id_rm]
  ngenes_tscore_path <- ngenes_tscore_path[-id_rm]
}

# add number of genes info 
df_pathR_info <- data.frame(path = pathR$pathID, ngenes_tscore = unname(ngenes_tscore_path), ngenes_path = unname(ngenes_path), stringsAsFactors = F)
df_pathR_info$genes <- unname(sapply(genes_path, function(x) paste0(x, collapse = ",")))
df_pathR_info$Array_id <- unname(sapply(genes_path, function(x) 
  paste0(gene_ann$Array_id[gene_ann$external_gene_name %in% x], collapse = ",")))

# compute mean/sd correlation for the genes belonging to the pathway (based on tscore)
df_pathR_info$mean_gene_corr <- NA
df_pathR_info$sd_gene_corr <- NA
df_pathR_info$mean_gene_abscorr <- NA
df_pathR_info$sd_gene_abscorr <- NA

genesID <- colnames(gene_exp)
for(i in 1:length(genes_path)){
  
  id <- which(genesID %in% genes_path[[i]])
  
  if(length(id)>1){
    # print(i)
    tmp <- cor(gene_exp[,id])
    tmp <- tmp[lower.tri(tmp, diag = F)]
    df_pathR_info$mean_gene_corr[i] <- mean(tmp)
    df_pathR_info$sd_gene_corr[i] <- sd(tmp)  
    df_pathR_info$mean_gene_abscorr[i] <- mean(abs(tmp))
    df_pathR_info$sd_gene_abscorr[i] <- sd(abs(tmp))
    
  }
  
}

# remove paths with one gene only
df_pathR_info <- df_pathR_info[df_pathR_info$ngenes_tscore >= 3 & 
                                 df_pathR_info$ngenes_tscore < 200 & 
                                 df_pathR_info$ngenes_path < 200, ]
df_pathR_info <- cbind(data.frame(pheno_id = paste0("path_Reactome_", 1:nrow(df_pathR_info)), stringsAsFactors = F), 
                       df_pathR_info)
pathR <- pathR[match(df_pathR_info$path, pathR$pathID), ]
pheno_pathR <- as.data.frame(t(pathR[, -1]))
pheno_pathR <- cbind(data.frame(Individual_ID = rownames(pheno_pathR), stringsAsFactors = F), pheno_pathR)
colnames(pheno_pathR)[-1] <- df_pathR_info$pheno_id

# save
write.table(pheno_pathR, file = "GENE_EXPR/Pathway_Reactome_scores_phenotypeFormat.txt",
            col.names = T, 
            row.names = F, 
            sep = '\t', 
            quote = F)

write.table(df_pathR_info, file = "GENE_EXPR/Pathway_Reactome_scores_phenotypeFormat_info.txt",
            col.names = T, 
            row.names = F, 
            sep = '\t', 
            quote = F)

print('pathScore reactome completed')

#######################################

# consider only pathaways that do not heave gene repetition, on pathwayScoreID add gene info
go <- get(load(GO_file))

go_name <- sapply(go, function(x) x$GOID)
go <- go[which(go_name %in% pathGO$pathID)]
go_name <- sapply(go, function(x) x$GOID)
go_path_name <- sapply(go, function(x) x$Term)
go_ont_name <- sapply(go, function(x) x$Ontology)
identical(go_name,  pathGO$pathID)

genes_path <- lapply(go, function(x) gene_ann$external_gene_name[gene_ann$external_gene_name %in% x$geneIds])
ngenes_path <-  sapply(go, function(x) length(unique(x$geneIds[x$geneIds != ""])))
ngenes_tscore_path <- sapply(genes_path, length)

# remove pathway with the same genes, recompute qvalue
rm_path <- c()
len <- c()
for(i in 1:length(genes_path)){
  # print(i)
  id <- which(sapply(genes_path, function(x) all(genes_path[[i]] %in% x) & all(x %in% genes_path[[i]])))
  len[i] <- length(id)
  ngenes_tmp <- ngenes_path[id]
  # take the one woth the lower amount of genes
  rm_path <- c(rm_path, go_name[id][-which.min(ngenes_tmp)])
}

rm_path <- unique(rm_path)
id_rm <- which(pathGO$pathID %in% rm_path)
if(length(id_rm)>0){
  pathGO <- pathGO[-id_rm,]
  go <- go[-id_rm]
  go_name <- sapply(go, function(x) x$GOID)
  go_path_name <- sapply(go, function(x) x$Term)
  go_ont_name <- sapply(go, function(x) x$Ontology)
  print(identical(go_name, pathGO$pathID))
  genes_path <- lapply(go, function(x) gene_ann$external_gene_name[gene_ann$external_gene_name %in% x$geneIds])
  ngenes_path <- ngenes_path[-id_rm]
  ngenes_tscore_path <- ngenes_tscore_path[-id_rm]
}

# add number of genes info 
df_pathGO_info <- data.frame(path = pathGO$pathID, 
			     path_name = go_path_name,
                             path_ont = go_ont_name,
                             ngenes_tscore = unname(ngenes_tscore_path), 
                             ngenes_path = unname(ngenes_path), stringsAsFactors = F)
df_pathGO_info$genes <- unname(sapply(genes_path, function(x) paste0(x, collapse = ",")))
df_pathGO_info$Array_id <- unname(sapply(genes_path, function(x) 
  paste0(gene_ann$Array_id[gene_ann$external_gene_name %in% x], collapse = ",")))

# compute mean/sd correlation for the genes belonging to the pathway (based on tscore)
df_pathGO_info$mean_gene_corr <- NA
df_pathGO_info$sd_gene_corr <- NA
df_pathGO_info$mean_gene_abscorr <- NA
df_pathGO_info$sd_gene_abscorr <- NA

genesID <- colnames(gene_exp)
for(i in 1:length(genes_path)){
  
  id <- which(genesID %in% genes_path[[i]])
  
  if(length(id)>1){
    # print(i)
    tmp <- cor(gene_exp[,id])
    tmp <- tmp[lower.tri(tmp, diag = F)]
    df_pathGO_info$mean_gene_corr[i] <- mean(tmp)
    df_pathGO_info$sd_gene_corr[i] <- sd(tmp)  
    df_pathGO_info$mean_gene_abscorr[i] <- mean(abs(tmp))
    df_pathGO_info$sd_gene_abscorr[i] <- sd(abs(tmp))
    
  }
  
}

# remove paths with one gene only
df_pathGO_info <- df_pathGO_info[df_pathGO_info$ngenes_tscore >= 3 & 
                                   df_pathGO_info$ngenes_tscore < 200 & 
                                   df_pathGO_info$ngenes_path < 200, ]
df_pathGO_info <- cbind(data.frame(pheno_id = paste0("path_GO_", 1:nrow(df_pathGO_info)), 
                                   stringsAsFactors = F), 
                       df_pathGO_info)
pathGO <- pathGO[match(df_pathGO_info$path, pathGO$pathID), ]

pheno_pathGO <- as.data.frame(t(pathGO[, -1]))
pheno_pathGO <- cbind(data.frame(Individual_ID = rownames(pheno_pathGO), stringsAsFactors = F), pheno_pathGO)
colnames(pheno_pathGO)[-1] <- df_pathGO_info$pheno_id

# save
write.table(pheno_pathGO, file = "GENE_EXPR/Pathway_GO_scores_phenotypeFormat.txt",
            col.names = T, 
            row.names = F, 
            sep = '\t', 
            quote = F)

write.table(df_pathGO_info, file = "GENE_EXPR/Pathway_GO_scores_phenotypeFormat_info.txt",
            col.names = T, 
            row.names = F, 
            sep = '\t', 
            quote = F)


