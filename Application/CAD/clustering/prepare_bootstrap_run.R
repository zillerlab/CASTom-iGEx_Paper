options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(data.table))
options(bitmapType = 'cairo', device = 'png')

parser <- ArgumentParser(description="bootstrap CAD samples for clustering")
parser$add_argument("--sampleAnnFile", type = "character", help = "original sample file")
parser$add_argument("--outFold", type = "character", help = "output folder")
parser$add_argument("--type_cluster", type = "character", help = "Cases, Controls or All")
parser$add_argument("--n_rep", type = "integer", help = "number of bootstrap replicates")
parser$add_argument("--bootstrap_perc", type = "integer", help = "percentage of samples to bootstrap")

args <- parser$parse_args()
sampleAnnFile <- args$sampleAnnFile
outFold <- args$outFold
type_cluster <- args$type_cluster
n_rep <- args$n_rep
bootstrap_perc <- args$bootstrap_perc

###############################
#sampleAnnFile="INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/covariateMatrix_CADHARD_All.txt"
#outFold="INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/bootstrap50/"
#type_cluster="Cases"
#n_rep=10
#bootstrap_perc=50
###############################

# read sample annotation file
sampleAnn <- read.table(sampleAnnFile, header=T, sep="\t")

if(type_cluster == 'Cases'){
  sampleAnn <- sampleAnn[sampleAnn$Dx == 1,]
}else{
  if(type_cluster == 'Controls'){
    sampleAnn <- sampleAnn[sampleAnn$Dx == 0,]
  }else{
    if(type_cluster != 'All')
      stop('type_cluster must be either Cases or Controls or All')
  }
}

for(i in 1:n_rep){
    print(i)
    set.seed(i + 2019)
    # sample without replacement
    sampleAnn_boot <- sampleAnn[sample(1:nrow(sampleAnn), size = round(nrow(sampleAnn)*bootstrap_perc/100), replace = F),]
    # save in outFold
    write.table(sampleAnn_boot, paste0(outFold, "covariateMatrix_CADHARD_", type_cluster, "_rep", i, ".txt"), sep="\t", quote=F, row.names=F, col.names=T)
}
