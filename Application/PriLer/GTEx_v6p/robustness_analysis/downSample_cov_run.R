# downsampling GTEx on a specific tissue

library(argparse)
options(bitmapType = 'cairo', device = 'png')

parser <- ArgumentParser(description="downsampling")

parser$add_argument("--covDat", type = "character", help = "file covariates")
parser$add_argument("--n_samples", type = "integer", default = 90, help = "number of new samples to consider")
parser$add_argument("--n_rep", type = "integer", default = 10, help = "number of repetitions")
parser$add_argument("--outFold", type = "character", help = "out Fold")

args <- parser$parse_args()
covDat <- args$covDat
n_samples <- args$n_samples
n_rep <- args$n_rep
outFold <- args$outFold

##########################
# covDat <- '/mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/Whole_Blood/covariates_EuropeanSamples.txt'
# n_samples <- 90
# n_rep <- 30
# outFold <- '/mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/Whole_Blood/robustness_analysis/'
##########################

sampleAnn <- read.table(covDat, h=T, stringsAsFactors = F)

for(i in 1:n_rep){
  
  set.seed(124+i)
  id <- sort(sample(1:nrow(sampleAnn), n_samples))
  new <- sampleAnn[id, ]
  
  write.table(file = sprintf('%scovariates_EuropeanSamples_rep%i.txt', outFold, i), x = new, quote = F, sep = '\t', col.names = T, row.names = F)
  
}
