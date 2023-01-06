# create covariate and pheno file for each cohort, exclude bad samples

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(Matrix))

parser <- ArgumentParser(description="create covariate and pheno file")

parser$add_argument("--cohort_name", type = "character", help = "name of the cohort (LT)")
parser$add_argument("--mdsFile", type = "character", help = "path file with mds componenets")
parser$add_argument("--sampleFile", type = "character", help = "path to sample file (plink format), contains also phenotype")
parser$add_argument("--removeSampleFile", type = "character", help = "file containing samples to remove (all cohorts) due to reltivenes")
# parser$add_argument("--allCovFile", type = "character", help = "file containing covariates (all cohorts): age and sex")
parser$add_argument("--outFold", type="character", help = "Output file [basename only]")

args <- parser$parse_args()
mdsFile <- args$mdsFile
sampleFile <- args$sampleFile
removeSampleFile <- args$removeSampleFile
cohort_name <- args$cohort_name
# allCovFile <- args$allCovFile
outFold <- args$outFold

################################################################
# cohort_name='German3'
# mdsFile = '/psycl/g/mpsukb/CAD/geno_qced_bf_imputation/German3/01_qc/covariates.txt'
# sampleFile = '/psycl/g/mpsukb/CAD/hrc_imputation/German3/oxford/ReplaceDots/G3_filtered_SampleInfos'
# removeSampleFile <- '/psycl/g/mpsukb/CAD/geno_qced_bf_imputation/mergedG1toWTC/mergedG1toWTC_filtBadSamples_AllSamplesToRemove_0125.txt'
# # allCovFile <- '/psycl/g/mpsukb/CAD/CAD_SchunkertLab_data/Phenotypes/Covariates_G1_G2_G3_G4_G5_LURIC_MG_CG_WTCCC.txt'
# outFold <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/German3/'
################################################################

# create a file associating cohorts names
file_cohorts <- data.frame(LT_name = c('German1', 'German2', 'German3', 'German4', 'German5', 'CG', 'LURIC', 'MG', 'WTCCC'), 
                           SM_name = c('GerMIFSI', 'GerMIFSII', 'GerMIFSIII', 'GerMIFSIV', 'GerMIFSV', 'Cardiogenics', 'LURIC', 'MIGen', 'WTCCC'))


samplesRM <- read.table(removeSampleFile, header = T, stringsAsFactors = F,  sep = '\t')
samplesRM <- samplesRM[samplesRM$cohort %in% file_cohorts$SM_name[file_cohorts$LT_name == cohort_name], ]

sampleID <- read.table(sampleFile, header = T, stringsAsFactors = F)
sampleID <- sampleID[-1, ]
mdsComp <- read.table(mdsFile, header = T, stringsAsFactors = F)

if(nrow(samplesRM)>0){
  sampleID <- sampleID[!sampleID$ID_1 %in% samplesRM$IID, ]  
}

id <- match(sampleID$ID_1,  mdsComp$FID)
mdsComp <- mdsComp[id, ]

# create covariate file
# change individual ID if start with a number add 'X' in front (avoid error in parse from PathwayDiff_analysis.R)
id_s <- unname(which(!sapply(sampleID$ID_1, function(x) is.na(as.numeric(strsplit(as.character(x), split = '')[[1]][1])))))
if(length(id_s)>0){
  tmp <- sapply(id_s, function(x) paste0('X', sampleID$ID_1[x]))
  new_id <- sampleID$ID_1
  new_id[id_s] <- tmp
}else{
  new_id <-  sampleID$ID_1
}
# substitute '+' (German2) with '_'
id_plus <- unname(which(sapply(new_id, function(x) length(strsplit(as.character(x), split = '[+]')[[1]])>1)))
if(length(id_plus)){
  new_id[id_plus] <- paste0(strsplit(as.character(new_id[id_plus]), split = '[+]')[[1]], collapse = '_')
}


# cov_tot <- read.table(allCovFile, h=T, stringsAsFactors = F)
# cov_tot <- cov_tot[cov_tot$genoSample_ID %in% sampleID$ID_1 & cov_tot$cohort == cohort_name, ]
# print(nrow(cov_tot) == nrow(sampleID))
# id <- sapply(sampleID$ID_1, function(x) which(x==cov_tot$genoSample_ID))
# cov_tot <- cov_tot[id, ]
# 
# if(!all(cov_tot$Sex == sampleID$sex)){
#   print('different sex annotation! use plink annotation')
# }

# covDat <- data.frame(Individual_ID = new_id, genoSample_ID = sampleID$ID_1, Dx = as.numeric(sampleID$pheno), Sex = as.numeric(sampleID$sex) - 1, Age = cov_tot$Age, stringsAsFactors = F)
# do not include age, info not present for CG and WTCCC
covDat <- cbind(data.frame(Individual_ID = new_id, genoSample_ID = sampleID$ID_1, Dx = as.numeric(sampleID$pheno), Sex = as.numeric(sampleID$sex) - 1, stringsAsFactors = F), 
                mdsComp[, !colnames(mdsComp) %in% c('FID', 'IID')])
write.table(file = paste0(outFold, 'covariateMatrix.txt'), x = covDat, col.names = T, row.names = F, quote = F, sep = '\t')

# create pheno file
# save only Dx
phenoDat <- covDat[, c('Individual_ID', 'Dx')]
write.table(file = paste0(outFold, 'phenoMatrix.txt'), x = phenoDat, col.names = T, row.names = F, quote = F, sep = '\t')




