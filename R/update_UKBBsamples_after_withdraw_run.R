# automatically update cov file
suppressPackageStartupMessages(library(argparse))

parser <- ArgumentParser(description="Update covdat file based on latest sample removal")
parser$add_argument("--samplewithdraw_file", type = "character", help = ".csv file from UKBB")
parser$add_argument("--covDat_file", type = "character", help = "sample annotation file used in the pipeline")
parser$add_argument("--string_name", type = "character", help = "string id to save new update")
parser$add_argument("--outFold", type="character", help = "Output fold")

args <- parser$parse_args()
samplewithdraw_file <- args$samplewithdraw_file
covDat_file <- args$covDat_file
string_name <- args$string_name
outFold <- args$outFold

# samplewithdraw_file <- "UKBB/phenotype_data/w34217_20230425_sampleTOremove.csv"
# covDat_file <- "CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW_202202.txt"
# string_name <- "202304"
# outFold <- "CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/"

sample_to_rm <- read.csv(samplewithdraw_file, header = F, stringsAsFactors = F)
sampleAnn <- read.table(covDat_file, header = T, stringsAsFactors = F)

sampleAnn_updated <- sampleAnn[!sampleAnn$genoSample_ID %in% sample_to_rm$V1, ]
write.table(x = sampleAnn_updated, file = sprintf("%scovariateMatrix_latestW_%s.txt", outFold, string_name), col.names=T, row.names=F, sep = "\t", quote = F)


