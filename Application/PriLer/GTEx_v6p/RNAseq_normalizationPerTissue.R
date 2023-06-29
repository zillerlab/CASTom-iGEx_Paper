# pre-processing RNAseq data for GTEx
# filter based on the tissue to take into account and QC described in "Genetic effects on gene expression across human tissues" supplementary (section 5.2)
# filter based on SMFRZE, NOTE: filtering of older version with new annotation!
library('stringr')

setwd('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/')

#### load sample info
sample_attributes <- read.delim('phs000424.v7.pht002743.v7.p2.c1.GTEx_Sample_Attributes.GRU.txt', header = T, stringsAsFactors = F, skip=10)
sample_info <- read.delim('phg000520.v2.GTEx_MidPoint.sample-info.MULTI/phg000520.v2_release_manifest.txt', header = T, stringsAsFactors = F, skip=15)
sub_pheno <- read.delim('phs000424.v7.pht002742.v7.p2.c1.GTEx_Subject_Phenotypes.GRU.txt', header = T, stringsAsFactors = F, skip=10)

#### load RNAseq sample info
RNAseq_sampleinfo <- read.table('phe000006.v2.GTEx_RNAseq.sample-info.MULTI/phe000006.v2_release_manifest.txt', header = T, stringsAsFactors = F)
RNAseq_metrics <- read.delim(gzfile('phe000006.v2.GTEx_RNAseq.expression-data-matrixfmt.c1/GTEx_Data_20150112_RNAseq_RNASeQCv1.1.8_metrics.tsv.gz'), header = T, stringsAsFactor = F) # neede for cell type specificity

# save ID for geno and RNAseq
SampleGeno <- sample_info[sample_info$SampleUse == 'Imputation_SNP',1:2]

# consider only subjects with genotype data
RNAseq_sampleinfo <- RNAseq_sampleinfo[RNAseq_sampleinfo$SubjectID %in% SampleGeno$SubjectID, ]
RNAseq_metrics <- RNAseq_metrics[RNAseq_metrics$Sample %in% RNAseq_sampleinfo$SampleID, ]

###################################################################################################
# for each subject, report the OMNI used and the sex
omni_tab <- sample_attributes[sample_attributes$SMAFRZE == 'OMNI',]
# check the samples name are the same 
all(omni_tab$SAMPID %in% SampleGeno$SampleID) # TRUE
id_OMNI5 <- c(which(!is.na(str_extract(omni_tab$SMGEBTCH, '5M'))), which(!is.na(str_extract(omni_tab$SMGEBTCH, 'OM5'))), which(!is.na(str_extract(omni_tab$SMGEBTCH, 'Om5'))))
id_OMNI25 <- which(!is.na(str_extract(omni_tab$SMGEBTCH, 'OM25')))
# length(unique(c(id_OMNI25, id_OMNI5))) # 450
new_var <- rep('OMNI_5M', nrow(omni_tab))
new_var[id_OMNI25] <- 'OMNI_2.5M'
id <- sapply(SampleGeno$SampleID, function(x) which(omni_tab$SAMPID == x))
SampleGeno$ArrayType <- new_var[id]
# update sex, age and race
SampleGeno$Sex <- sapply(SampleGeno$SubjectID, function(x) sub_pheno$SEX[sub_pheno$SUBJID == x])
SampleGeno$Age <- sapply(SampleGeno$SubjectID, function(x) sub_pheno$AGE[sub_pheno$SUBJID == x])
SampleGeno$Race <- sapply(SampleGeno$SubjectID, function(x) sub_pheno$RACE[sub_pheno$SUBJID == x]) 
# NOTE: race = 3 corresponds to white, 
# see https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/variable.cgi?study_id=phs000424.v2.p1&phv=169064&phd=3910&pha=&pht=2742&phvf=&phdf=&phaf=&phtf=&dssp=1&consent=&temp=1

# save 
write.table(SampleGeno, file = 'SampleGeno_Info.txt', col.names = T, row.names = F, sep = '\t', quote = F)

###################################################################################################
# consider only RNA-seq
sample_attributes <- sample_attributes[sample_attributes$SAMPID %in% RNAseq_sampleinfo$SampleID,]
# filter out bad quality samples
sample_attributes <- sample_attributes[sample_attributes$SMAFRZE != 'EXCLUDE',]
# filter out tissues with less than 70 samples
tiss_excl <- names(which(table(sample_attributes$SMTSD) < 70))
sample_attributes <- sample_attributes[!sample_attributes$SMTSD %in% tiss_excl, ]

RNAseq_sampleinfo <- RNAseq_sampleinfo[RNAseq_sampleinfo$SampleID %in% sample_attributes$SAMPID, ]
RNAseq_metrics <- RNAseq_metrics[RNAseq_metrics$Sample %in% sample_attributes$SAMPID,]

##################################################################################################
# for each tissue to be considered, create final annotation file
tissue_to_exclude <- c('Testis', 'Vagina', 'Ovary', 'Uterus', 'Prostate')
tissues <- setdiff(unique(RNAseq_metrics$Note), tissue_to_exclude)
tissues_name <- sapply(tissues, function(x) paste(strsplit(x, split = ' - ')[[1]], collapse="_"))
tissues_name <- sapply(tissues_name, function(x) paste(strsplit(x, split = ' \\(|\\)')[[1]], collapse="_"))
tissues_name <- sapply(tissues_name, function(x) paste(strsplit(x, split = ' ')[[1]], collapse="_"))
# write file for tissue 
df_t <- data.frame(tissues = tissues_name, tissues_originalName = tissues, n_samples = sapply(tissues, function(x) length(which(RNAseq_metrics$Note == x))))
write.table(df_t, file = 'Tissues_Names.txt', col.names = T, row.names = F, sep = '\t', quote = F)


extract_annotation <- function(RNAseq_sampleinfo, RNAseq_metrics, sample_attributes, tissue){
  
  ann <- RNAseq_metrics[RNAseq_metrics$Note == tissue,]
  subj <- sapply(ann$Sample, function(x) RNAseq_sampleinfo$SubjectID[RNAseq_sampleinfo$SampleID == x])
  names(subj) <- NULL
  ann <- data.frame(SubjectID = subj, SampleID = ann$Sample, stringsAsFactors = F)
  ord <- sapply(ann$SampleID, function(x) which(sample_attributes$SAMPID == x))
  names(ord) <- NULL
  ann <- cbind(ann, sample_attributes[ord,c('SMTS', 'SMTSD')])
  colnames(ann)[3:4] <- c('Tissue_Type','Tissue_Site_Detail_field')
  tissue_name <- paste(strsplit(tissue, split = ' - ')[[1]], collapse="_")
  tissue_name <- paste(strsplit(tissue_name, split = ' \\(|\\)')[[1]], collapse="_")
  tissue_name <- paste(strsplit(tissue_name, split = ' ')[[1]], collapse="_")
  
  write.table(file = sprintf('../RNAseq_data/%s/SampleRNAseq.txt', tissue_name), x = ann, col.names = T, row.names = F, quote = F, sep = '\t')
  
}


# save
for(t in tissues){
  
  print(t)
  extract_annotation(RNAseq_sampleinfo, RNAseq_metrics, sample_attributes, t)
  
} 

#######################################################
############ normalize for each tissue ################
#######################################################
# filter genes based on https://storage.googleapis.com/gtex-public-data/Portal_Analysis_Methods_v6p_08182016.pdf

library('RNOmni') # inverse rank normal distribution
library('limma') # quantile normalization
library('peer') # compute peer cofounders

# load gene count
gene_counts <- read.table(gzfile('phe000006.v2.GTEx_RNAseq.expression-data-matrixfmt.c1/GTEx_Data_20150112_RNAseq_RNASeQCv1.1.8_gene_reads.gct.gz'), header = T, stringsAsFactors = F, skip=2)
names_new <- sapply(colnames(gene_counts[3:ncol(gene_counts)]), function(x) paste(strsplit(x = x, split = '.', fixed = T)[[1]], collapse="-"))
names(names_new) <- NULL
colnames(gene_counts)[3:ncol(gene_counts)] <- names_new

# load gene rpkm
gene_rpkm <- read.table(gzfile('phe000006.v2.GTEx_RNAseq.expression-data-matrixfmt.c1/GTEx_Data_20150112_RNAseq_RNASeQCv1.1.8_gene_rpkm.gct.gz'), header = T, stringsAsFactors = F, skip=2)
names_new <- sapply(colnames(gene_rpkm[3:ncol(gene_rpkm)]), function(x) paste(strsplit(x = x, split = '.', fixed = T)[[1]], collapse="-"))
names(names_new) <- NULL
colnames(gene_rpkm)[3:ncol(gene_rpkm)] <- names_new

# store annotation
# identical(gene_rpkm[,1:2], gene_counts[,1:2]) # T
gene_annotation <- gene_counts[,1:2]
# add version ensembl without dots
gene_annotation$ensembl <- sapply(gene_annotation[,1], function(x) strsplit(x, split = '[.]')[[1]][1])
gene_counts <- gene_counts[, -(1:2)]
gene_rpkm <- gene_rpkm[, -(1:2)]

###
print(dim(gene_counts))
print(dim(gene_rpkm))
print(dim(gene_annotation))
###

# function to determine number of factors for PEER based on number of samples
n_factors <- function(n){
  
  if(n<150){k <- 15
  }else{
    if(n>=250){k <- 35
    }else{
      k <- 30
    }
  }
  
  return(k)
  
}

# for each tissue, filter genes and save the normalized matrix 
filter_gene <- function(gene_rpkm, gene_count, gene_annotation, tissue){
  
  
  ann <- read.table(file = sprintf('../RNAseq_data/%s/SampleRNAseq.txt', tissue), header = T, stringsAsFactors = F, sep = '\t')
  tmp_rpkm <- gene_rpkm[, which(colnames(gene_rpkm) %in% ann$SampleID)]
  tmp_count <- gene_counts[, which(colnames(gene_counts) %in% ann$SampleID)]
  tmp_annotation <- gene_annotation
  
  # based on rpkm
  id <- which(apply(tmp_rpkm, 1, function(x) length(which(x>0.1))>= 10))
  if(length(id)>0){
    tmp_rpkm <- tmp_rpkm[id, ]
    tmp_count <- tmp_count[id, ]
    tmp_annotation <- tmp_annotation[id, ]
  }
  sprintf('based on rpkm: %i', nrow(tmp_annotation))
  
  # based on counts
  id <- which(apply(tmp_count, 1, function(x) length(which(x>=6))>= 10))
  if(length(id)>0){
    tmp_rpkm <- tmp_rpkm[id, ]
    tmp_count <- tmp_count[id, ]
    tmp_annotation <- tmp_annotation[id, ]
  }
  sprintf('based on counts: %i', nrow(tmp_annotation))
  
  # quantile normalization
  norm_rpkm <- normalizeBetweenArrays(t(as.matrix(tmp_rpkm)), method = 'quantile')
  # inverse rank gaussian normalization
  final_expr <- apply(norm_rpkm, 2, rankNorm)
  # save final matrix
  final_mat <- cbind(data.frame(geneNames = tmp_annotation$ensembl),t(final_expr))
  write.table(final_mat,gzfile(sprintf("../RNAseq_data/%s/RNAseq_norm.txt.gz", tissue)), row.names = F, col.names = T, sep = '\t', quote = F)
  
  # compute PEER
  model <- PEER()
  PEER_setPhenoMean(model,as.matrix(final_expr))
  # dim(PEER_getPhenoMean(model))
  # determine number of factors based on
  # 15 factors for N < 150, 30 factors for 150 ≤ N < 250, and 35 factors for N ≥ 250
  K <- n_factors(nrow(final_expr))
  PEER_setNk(model,K)
  # PEER_getNk(model)
  PEER_update(model)
  factors <- PEER_getX(model)
  # save PEER factors, used as covariates in eQTL analysis
  df <- as.data.frame(t(factors))
  colnames(df) <- rownames(final_expr)
  write.table(file = sprintf("../RNAseq_data/%s/PEERfactors.txt", tissue),x = df,  row.names = F, col.names = T, sep = '\t', quote = F)
  
}

for(t in tissues_name){
  
  print(t)
  filter_gene(gene_rpkm, gene_count, gene_annotation, t)
  
}






