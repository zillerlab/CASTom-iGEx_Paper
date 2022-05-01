# create cov and pheno for each cohort of SCZ

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(Matrix))

parser <- ArgumentParser(description="create covariate and pheno file")

parser$add_argument("--cohort_name", type = "character", help = "name of the cohort")
parser$add_argument("--mdsFile", type = "character", help = "path file with mds componenets")
parser$add_argument("--sampleFile", type = "character", help = "path to sample file (plink format), contains also phenotype")
parser$add_argument("--outFold", type="character", help = "Output file [basename only]")

args <- parser$parse_args()
mdsFile <- args$mdsFile
cohort_name <- args$cohort_name
sampleFile <- args$sampleFile
outFold <- args$outFold

################################################################
# cohort_name='scz_s234_eur'
# mdsFile = '//home/pgcdac/DWFV2CJb8Piv_0116_pgc_data/scz/wave2/v1/prune.bfile.cobg.PGC_SCZ49.sh2.menv.mds_cov'
# sampleFile = '//home/pgcdac/DWFV2CJb8Piv_0116_pgc_data/scz/wave2/v1/scz_s234_eur-qc.fam'
# outFold <- '/home/luciat/eQTL_PROJECT/INPUT_DATA/Covariates/'
################################################################

# load mds file
mds_res <- read.table(mdsFile, h=T, stringsAsFactors = F)
PC_to_select_old <- c(1,2,3,4,5,6,7,9,15,18)
# PC_to_select <- 1:10
PC_to_select <- 1:5

# load sample file
sample_info <- read.table(sampleFile, h=F,stringsAsFactors = F)
new_id <- paste(sample_info$V1, sample_info$V2, sep = '_')
sample_info <- cbind(data.frame(genoSample_ID = new_id, Individual_ID = new_id, stringsAsFactors = F), Dx = sample_info[, 6])
# colnames(sample_info)[-(1:2)] <- c('Sex', 'Dx')
# do not use sex as covariate, missing for s234

# remove samples with no sex or Dx
sample_info <- sample_info[sample_info$Dx %in% c(1,2),]

# find common set in mds
mds_cohort <- mds_res[paste(mds_res$FID, mds_res$IID, sep = '_') %in%  sample_info$genoSample_ID, c('FID', 'IID', paste0('C', PC_to_select))]
mds_cohort_old <- mds_res[paste(mds_res$FID, mds_res$IID, sep = '_') %in%  sample_info$genoSample_ID, c('FID', 'IID', paste0('C', PC_to_select_old))]

# match with sample file
id <- match(paste(mds_cohort$FID, mds_cohort$IID, sep = '_'), sample_info$genoSample_ID)
sample_info <- sample_info[id, ]
print(identical(sample_info$Individual_ID, paste(mds_cohort$FID, mds_cohort$IID, sep = '_')))
print(c(length(unique(sample_info$Individual_ID)), nrow(sample_info)))

covDat <- data.frame(Individual_ID = sample_info$Individual_ID, genoSample_ID = sample_info$genoSample_ID, Dx = sample_info$Dx-1 , stringsAsFactors = F)
covDat <- cbind(covDat, mds_cohort[, paste0('C', PC_to_select)])

phenoDat <- covDat[, c('Individual_ID', 'Dx')]

# save
write.table(x = covDat, file = sprintf('%s/%s.covariateMatrix.txt', outFold, cohort_name), quote = F, col.names = T, sep = '\t', row.names = F)
write.table(x = phenoDat, file = sprintf('%s/%s.phenoMatrix.txt', outFold, cohort_name), quote = F, col.names = T, sep = '\t', row.names = F)

### old version 
# match with sample file
id <- match(paste(mds_cohort_old$FID, mds_cohort_old$IID, sep = '_'), sample_info$genoSample_ID)
sample_info <- sample_info[id, ]
print(identical(sample_info$Individual_ID, paste(mds_cohort_old$FID, mds_cohort_old$IID, sep = '_')))
print(c(length(unique(sample_info$Individual_ID)), nrow(sample_info)))

covDat <- data.frame(Individual_ID = sample_info$Individual_ID, genoSample_ID = sample_info$genoSample_ID, Dx = sample_info$Dx-1 , stringsAsFactors = F)
covDat <- cbind(covDat, mds_cohort_old[, paste0('C', PC_to_select_old)])

phenoDat <- covDat[, c('Individual_ID', 'Dx')]

# save
write.table(x = covDat, file = sprintf('%s/%s.covariateMatrix_old.txt', outFold, cohort_name), quote = F, col.names = T, sep = '\t', row.names = F)
write.table(x = phenoDat, file = sprintf('%s/%s.phenoMatrix_old.txt', outFold, cohort_name), quote = F, col.names = T, sep = '\t', row.names = F)

