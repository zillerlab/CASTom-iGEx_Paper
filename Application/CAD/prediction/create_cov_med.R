# define subset of samples to be used for clustering

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(coin))

parser <- ArgumentParser(description="create covariates to correct for Treatments")
parser$add_argument("--fold", type = "character", default = './', help = "working directory")

args <- parser$parse_args()
fold <- args$fold

###############################################################################
# fold <- 'INPUT_DATA_GTEx/CAD/Covariates/UKBB/'
###############################################################################

setwd(fold)

phenoInfo <- fread('phenotypeDescription_PHESANTproc_CADrelatedpheno_annotated.txt', h=T, stringsAsFactors=F, data.table=F) 
phenoICDInfo <- fread('phenotypeDescription_manualproc_ICD9-10_OPCS4.txt', h=T, stringsAsFactors=F, data.table=F) 

sampleAnn <- fread('covariateMatrix_latestW.txt', h=T, stringsAsFactors=F, data.table=F) # use to match the other files
phenoDat <- fread('phenoMatrix.txt', h=T, stringsAsFactors=F, data.table = F)
sampleAnn_tot <- fread('covariatesMatrix_batchInfo.txt', h=T, stringsAsFactors=F, data.table=F)

sampleAnn_tot <- sampleAnn_tot[match(sampleAnn$Individual_ID, sampleAnn_tot$Individual_ID),]
phenoDat <- phenoDat[match(sampleAnn$Individual_ID, phenoDat$Individual_ID),]

# load phenotypeMatrices
pheno_names <- c('Medication')
phenoDat_endo <- list()
for(i in 1:length(pheno_names)){
  print(pheno_names[i])
  tmp <- fread(sprintf('phenotypeMatrix_%s.txt', pheno_names[i]), h=T, stringsAsFactors=F, data.table = F)
  common_s <- intersect(sampleAnn$Individual_ID, tmp$Individual_ID)
  tmp <- tmp[match(common_s, tmp$Individual_ID),]
  rownames(tmp) <- tmp$Individual_ID
  tmp <- tmp[, -1]
  phenoDat_endo[[i]] <- tmp
}

if(!all(apply(sapply(phenoDat_endo, function(x) rownames(x)), 1, function(y) length(unique(y)) == 1))){stop('wrong sample annotation')}
phenoDat_endo <- do.call(cbind, phenoDat_endo)
identical(rownames(phenoDat_endo), sampleAnn$Individual_ID)
sampleAnn <- cbind(sampleAnn, data.frame(Age = sampleAnn_tot$Age))

# add medication info as covariates for endophenotype testing
pheno_id_tmp <- phenoInfo$pheno_id[phenoInfo$pheno_type %in% 'Medication' & (!phenoInfo$FieldID %in% c('6153', '6177')) & phenoInfo$pheno_id != '2492' & 
                                     phenoInfo$Coding_meaning != 'None of the above']
phenoInfo_tmp <- phenoInfo[phenoInfo$pheno_id %in% pheno_id_tmp,]
tmp <- sampleAnn[, c('Individual_ID', 'Dx', paste0('PC', 1:10), 'Age', 'Gender')]
tmp <- cbind(tmp, phenoDat_endo[, pheno_id_tmp])
colnames(tmp)[colnames(tmp) %in% pheno_id_tmp] <- paste0('p', pheno_id_tmp)
pheno_id_tmp <- phenoInfo$pheno_id[phenoInfo$FieldID %in% c('6153', '6177') & phenoInfo$Coding_meaning != 'None of the above' & (!phenoInfo$pheno_id %in% c('6153_5', '6153_4'))]
phenoInfo_tmp <- rbind(phenoInfo_tmp, phenoInfo[phenoInfo$pheno_id %in% pheno_id_tmp,])

#_1
id_bothna <- rowSums(is.na(phenoDat_endo[, c('6153_1', '6177_1')])) == 2
tmp <- cbind(tmp, v1 = rep(NA, nrow(tmp)))
tmp$v1[!id_bothna] <-  rowSums(phenoDat_endo[, c('6153_1', '6177_1')] >=1, na.rm=T)[!id_bothna]
colnames(tmp)[ncol(tmp)] <- 'p6153_6177_1'

#_2
id_bothna <- rowSums(is.na(phenoDat_endo[, c('6153_2', '6177_2')])) == 2
tmp <- cbind(tmp, v1 = rep(NA, nrow(tmp)))
tmp$v1[!id_bothna] <-  rowSums(phenoDat_endo[, c('6153_2', '6177_2')] >=1, na.rm=T)[!id_bothna]
colnames(tmp)[ncol(tmp)] <- 'p6153_6177_2'

#_3
id_bothna <- rowSums(is.na(phenoDat_endo[, c('6153_3', '6177_3')])) == 2
tmp <- cbind(tmp, v1 = rep(NA, nrow(tmp)))
tmp$v1[!id_bothna] <-  rowSums(phenoDat_endo[, c('6153_3', '6177_3')] >=1, na.rm=T)[!id_bothna]
colnames(tmp)[ncol(tmp)] <- 'p6153_6177_3'

write.table(tmp, file = 'covariateMatrix_withMedication.txt', col.names = T, row.names = F, sep = '\t', quote = F)
write.table(phenoInfo_tmp[, 1:14], file = 'phenotypeDescription_covariateMatrix_withMedication.txt', col.names = T, row.names = F, sep = '\t', quote = F)



