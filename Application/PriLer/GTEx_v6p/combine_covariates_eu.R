# combine covariates for each tissue

tissues_name <- read.table('/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/Tissues_Names.txt', header = T, stringsAsFactors = F, sep = '\t')

setwd('/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/')

gen_pca <- read.table(gzfile('GTEx_v6p/phg000520.v2.GTEx_MidPoint.genotype-qc.MULTI/Imputation/GTEx_Analysis_2015-01-12_OMNI_2.5M_5M_450Indiv_PostImput_20genotPCs.txt.gz'), header = T, stringsAsFactors = F)
gen_ann <- read.table('GTEx_v6p/SampleGeno_Info.txt', header = T, stringsAsFactors = F)

print(getwd())

for(t in tissues_name[,1]){
  
  print(t)
  
  sample_ann <- read.table(sprintf('RNAseq_data/%s/SampleRNAseq.txt', t), stringsAsFactors = F, header = T, sep ='\t')
  peer_fact <- read.table(sprintf('RNAseq_data/%s/PEERfactors.txt', t), stringsAsFactors = F, header = T, sep ='\t')
  names_new <- sapply(colnames(peer_fact), function(x) paste(strsplit(x = x, split = '.', fixed = T)[[1]], collapse="-"))
  names(names_new) <- NULL
  colnames(peer_fact) <- names_new
  
  # match geno and RNA
  covMat <- data.frame(Individual_ID = gen_ann$SubjectID[gen_ann$SubjectID %in% sample_ann$SubjectID], stringsAsFactors = F)
  id_gen <- sapply(covMat$Individual_ID, function(x) which(x == gen_ann$SubjectID))
  covMat$genoSample_ID <- gen_ann$SampleID[id_gen]
  
  id_rna <- sapply(covMat$Individual_ID, function(x) which(x == sample_ann$SubjectID))
  covMat$RNASample_ID <- sample_ann$SampleID[id_rna]
  
  id_peer <-  sapply(covMat$RNASample_ID, function(x) which(x == colnames(peer_fact)))
  covMat <- cbind(covMat, t(peer_fact))
  colnames(covMat)[4:ncol(covMat)] <- paste0('PEER_f', 1:nrow(peer_fact))
  
  id_pca <- sapply(covMat$genoSample_ID, function(x) which(x == gen_pca$FID))
  covMat <- cbind(covMat, gen_pca[id_pca, colnames(gen_pca) %in% c('C1', 'C2', 'C3')])
  colnames(covMat)[(ncol(covMat)-2):ncol(covMat)] <- paste0('PC', 1:3)
  
  covMat$ArrayPl  <- gen_ann$ArrayType[id_gen]
  covMat$ArrayPl[covMat$ArrayPl == 'OMNI_2.5M'] = 0
  covMat$ArrayPl[covMat$ArrayPl == 'OMNI_5M'] = 1
  
  covMat$Sex <- gen_ann$Sex[id_gen] -1
  
  # consider only European
  eu_samples <- gen_ann$SubjectID[gen_ann$Race == 3]
  covMat <- covMat[covMat$Individual_ID %in% eu_samples,]
  
  # save final table
  write.table(file = sprintf('Covariates/%s/covariates_EuropeanSamples.txt', t), x = covMat, quote = F, col.names = T, row.names = F, sep = '\t')
  
}

