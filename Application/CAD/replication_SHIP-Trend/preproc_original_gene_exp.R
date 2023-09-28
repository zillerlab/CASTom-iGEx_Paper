library("dplyr")

setwd('/psycl/g/mpsziller/lucia/CAD_SHIP/GENE_EXPR/')

gene_ann <- read.delim(sprintf("HumanHT-12_V3_0_R3_11283641_A_probes.txt"), header = T, stringsAsFactors = F)
gene_exp <- read.table(gzfile(sprintf("SHIP-TREND_GX_plate01-14_QuantileNormalized.log2Transformd-zz_transposed-resid-SHIP_2022_27.txt.gz")), 
                       h=T, stringsAsFactors = F)

# samples on the column, add external_gene_name column. 
# collapse duplicate names and remove NAs

gene_exp <- t(gene_exp) 

n_char <- unique(nchar(rownames(gene_exp)))
gene_ann$new_id <- sapply(gene_ann$Array_Address_Id, 
                          function(x) paste0("X", paste0(rep("0", n_char - nchar(x) -1), collapse = ""), x))

gene_ann <- gene_ann %>% 
  dplyr::filter(Symbol != "" & !is.na(Symbol))
  
gene_ann_red <- gene_ann %>%
  dplyr::group_by(Symbol) %>%
  dplyr::summarise(n_comb = n(), 
                   Entrez_Gene_ID = paste0(unique(Entrez_Gene_ID), collapse = ","), 
                   new_id_comb = paste0(new_id, collapse = ",")) %>%
  dplyr::arrange(n_comb)

gene_exp_single <- gene_exp[gene_ann_red$new_id_comb[gene_ann_red$n_comb == 1],]
rownames(gene_exp_single) <- gene_ann_red$Symbol[match(rownames(gene_exp_single), gene_ann_red$new_id_comb)]

gene_ann_multiple <- gene_ann_red %>% filter(n_comb > 1)
gene_exp_multiple <- matrix(nrow = nrow(gene_ann_multiple), ncol = ncol(gene_exp))
rownames(gene_exp_multiple) <- gene_ann_multiple$Symbol
colnames(gene_exp_multiple) <- colnames(gene_exp)

for(i in 1:nrow(gene_ann_multiple)){
  id_genes <- strsplit(gene_ann_multiple$new_id_comb[i], split = "[,]")[[1]]
  gene_exp_multiple[i, ] <- colMeans(gene_exp[id_genes, ])
}

gene_exp_new <- rbind(gene_exp_multiple, gene_exp_single)
gene_exp_new <- gene_exp_new[, colSums(is.na(gene_exp_new)) == 0]
# remove genes with low sd
SD_THR = 0.10
sd_genes <- apply(gene_exp_new, 1, sd)
id_keep <- sd_genes > SD_THR
gene_exp_new <- gene_exp_new[id_keep, ]
gene_ann_red <- gene_ann_red[match(rownames(gene_exp_new), gene_ann_red$Symbol),]

# combine
gene_exp_new <- cbind(gene_ann_red, as.data.frame(gene_exp_new))
gene_exp_new <- gene_exp_new %>% rename(external_gene_name = Symbol, Array_id = new_id_comb)

# save file
write.table(x = gene_exp_new, file = "Filtered_SHIP-TREND_GX_plate01-14_QuantileNormalized.log2Transformd-zz_transposed-resid-SHIP_2022_27.txt",
              quote = F, row.names = F, col.names = T, sep = "\t")


#### modification ###
options(stringsAsFactors=F)
options(max.print=1000)
tab <- read.table("/psycl/g/mpsziller/lucia/CAD_SHIP/Results/PriLer/Whole_Blood/predictedTscores.txt",sep="\t",header=T)
tab2 <- read.table("/psycl/g/mpsziller/lucia/CAD_SHIP/Results/PriLer/Liver/predictedTscores.txt",sep="\t",header=T)
expDat <- read.table("/psycl/g/mpsziller/lucia/CAD_SHIP/GENE_EXPR/Filtered_SHIP-TREND_GX_plate01-14_QuantileNormalized.log2Transformd-zz_transposed-resid-SHIP_2022_27.txt",sep="\t",header=T)
rDat <- expDat[is.element(expDat[,1],tab[,1])|is.element(expDat[,1],tab2[,1]),]
write.table(rDat,"Filtered_SHIP-TREND_GX_plate01-14_QuantileNormalized.log2Transformd-zz_transposed-resid-SHIP_2022_27_filtered_WB_Liver.txt",sep="\t",quote=F,row.names=F)

