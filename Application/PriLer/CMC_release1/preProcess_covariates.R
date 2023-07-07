# combine Covariates in a unique file

setwd('/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Covariates')

Clinical_dat <- read.table('CMC_MSSM-Penn-Pitt_Clinical.txt', header = T, stringsAsFactors = F, sep = '\t')
RNA_metadata <- read.csv('CMC_MSSM-Penn-Pitt_DLPFC_mRNA-metaData.csv', header = T, stringsAsFactors = F)
ancMat <- read.table('CMC_MSSM-Penn-Pitt_DLPFC_DNA_IlluminaOmniExpressExome_GemToolsAncestry.tsv', header = T, stringsAsFactors = F, sep = '\t')
clustLIB_dat <- read.table('CMC_MSSM-Penn-Pitt_DLPFC_clusteredLIB.txt', stringsAsFactors = F, header = T, sep = '\t')

# used to consider good quality samples
RNAseq_samples <- read.table('/ziller/Michael/CommonMind/SCZ/RNA-Seq_normalized/Gene/EXCLUDE ANCESTRY + SVA/Samples_name.txt', header = F, stringsAsFactors = F)
RNAseq_samples <- unname(t(RNAseq_samples)[-1,])

# consider only caucasian
Clinical_dat <- Clinical_dat[Clinical_dat$Ethnicity == 'Caucasian', ]
# match with RNA samples
rna_samples_fin <- intersect(Clinical_dat$DLPFC_RNA_Sequencing_Sample_ID, RNAseq_samples)
# filter tables
Clinical_dat <- Clinical_dat[Clinical_dat$DLPFC_RNA_Sequencing_Sample_ID %in% rna_samples_fin, ]
RNA_metadata <- RNA_metadata[RNA_metadata$DLPFC_RNA_Sequencing_Sample_ID %in% rna_samples_fin , ]
ancMat <- ancMat[ancMat$Genotyping_Sample_ID %in% Clinical_dat$Genotyping_Sample_ID,]

# create covaiate matrix 
cov_mat <- data.frame(Individual_ID = Clinical_dat$Individual_ID, genoSample_ID = Clinical_dat$Genotyping_Sample_ID, 
                      RNASample_ID = Clinical_dat$DLPFC_RNA_Sequencing_Sample_ID, Dx = Clinical_dat$Dx, Institution = Clinical_dat$Institution, 
                      Sex = Clinical_dat$Gender, AOD = Clinical_dat$Age_of_Death, PMI = Clinical_dat$PMI_hrs, stringsAsFactors = F)

metadata_id <- sapply(cov_mat$RNASample_ID, function(x) which(RNA_metadata$DLPFC_RNA_Sequencing_Sample_ID == x))
RNA_metadata <- RNA_metadata[metadata_id, ]
cov_mat$RIN <- RNA_metadata$DLPFC_RNA_isolation_RIN
cov_mat$RIN2 <- (cov_mat$RIN)^2
clust <- sapply(RNA_metadata$DLPFC_RNA_Sequencing_Library_Batch, function(x) clustLIB_dat$Cluster[x == clustLIB_dat$Library_Batch])
cov_mat$clustLIB <- clust

anc_id <- sapply(cov_mat$genoSample_ID, function(x) which(ancMat$Genotyping_Sample_ID == x))
ancMat <- ancMat[anc_id,]
cov_mat <- cbind(cov_mat, ancMat[,3:7])

cov_mat$Dx[cov_mat$Dx %in% c('AFF', 'BP')] <- 'AFF_BP'

# save
write.table(x = cov_mat, file = 'covariateMatrix_eQTL.txt', col.names = T, row.names = F, sep = '\t', quote = F)
