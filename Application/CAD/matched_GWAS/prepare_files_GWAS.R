options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))

setwd('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/')

covariate_file <- 'INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt'
phenotype_file <- 'INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenoMatrix_updateCADHARD.txt'
fam_file <- 'INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/plink_format/chr1/Genotype_CAD_UKBB_chr1.fam'

covariate <- read.table(covariate_file, sep = '\t', h=T)
phenotype <- read.table(phenotype_file, sep = '\t', h=T)
fam_tab <- read.table(fam_file, sep = ' ')

# create new fam file to use proper CAD phenotype
fam_updated <- fam_tab
fam_updated$V6 <- 1
fam_updated$V6[paste0('X', fam_updated$V1) %in% phenotype$Individual_ID[phenotype$CAD_HARD == 1]] <- 2
# save
write.table(file = 'INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/plink_format/Genotype_CAD_UKBB.fam', 
            x = fam_updated, sep = ' ', quote = F, col.names = F, row.names = F)

# save proper covariate file (same order as fam)
covariate_updated <- covariate
covariate_updated$Individual_ID <- covariate_updated$genoSample_ID
colnames(covariate_updated)[1:2] <- c('FID', 'IID')
covariate_updated <- covariate_updated[, !colnames(covariate_updated) %in% 'Dx']
# match with fam
covariate_updated <- covariate_updated[match(fam_updated$V1, covariate_updated$FID), ]
print(identical(covariate_updated$FID, fam_updated$V1))

write.table(file = 'INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/plink_format/Genotype_CAD_UKBB_covariates.txt', 
            x = covariate_updated, sep = ' ', quote = F, col.names = T, row.names = F)
