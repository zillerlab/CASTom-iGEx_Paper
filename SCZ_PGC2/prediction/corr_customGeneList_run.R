#### code written by Lucia Trastulla, e-mail: lucia_trastulla@psych.mpg.de ####
# save beta, se, zcores, phenotype already processed, use custom pathway structure

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(qvalue))
suppressPackageStartupMessages(library(lattice))
suppressPackageStartupMessages(library(MASS))
suppressPackageStartupMessages(library(lmtest))
suppressPackageStartupMessages(library(doParallel))
suppressPackageStartupMessages(library(data.table))


parser <- ArgumentParser(description="compute correlation among set of genes")
parser$add_argument("--gene_list", type = "character", help = "gene list among which to compute correlation")
parser$add_argument("--sampleAnn_file", type = "character", help = "file with sample info for new genotype data, must contain Dx column (0 controls 1 cases)")
parser$add_argument("--thr_reliableGenes", type = "double", nargs = '*', default = c(0.01, 0), help = "threshold for reliable genes: dev_geno_tot and test_dev_geno")
parser$add_argument("--inputFold", type = "character", help = "Folde with results from pathway analysis")
parser$add_argument("--geneAnn_file", type = "character", help = "file with gene info from train, to be filtered")
parser$add_argument("--functR", type = "character", help = "Rscript with functions to be used")
parser$add_argument("--geneSetName", type = "character", help = "name for saving")
parser$add_argument("--outFold", type="character", help = "Output file [basename only]")

args <- parser$parse_args()
gene_list <- args$gene_list
sampleAnn_file <- args$sampleAnn_file
thr_reliableGenes <- args$thr_reliableGenes
geneAnn_file <- args$geneAnn_file
inputFold <- args$inputFold
functR <- args$functR
geneSetName <- args$geneSetName
outFold <- args$outFold

# ##########################################################################################
# gene_list <- 'INPUT_DATA/list_genes_SCZLoF.txt'
# outFold <- 'OUTPUT_CMC/predict_PGC/200kb/scz_ersw_eur/devgeno0.01_testdevgeno0/'
# thr_reliableGenes <- c(0.01,0)
# sampleAnn_file <- 'INPUT_DATA/Covariates/scz_ersw_eur.covariateMatrix_old.txt'
# inputFold <- 'OUTPUT_CMC/predict_PGC/200kb/scz_ersw_eur/devgeno0.01_testdevgeno0/'
# geneAnn_file <- 'OUTPUT_CMC/train_CMC/200kb/resPrior_regEval_allchr.txt'
# functR <- '/home/luciat/priler_project/Software/model_prediction/pheno_association_functions.R'
# # ##########################################################################################


source(functR)

# load sample annotation
sampleAnn <- read.table(sampleAnn_file, h=T, stringsAsFactors=F)

# load gene annotation
geneAnn <- read.table(geneAnn_file, h=T, stringsAsFactors = F, sep = '\t')
geneAnn <- geneAnn[!(is.na(geneAnn$dev_geno) | is.na(geneAnn$test_dev_geno)), ]
geneAnn <- geneAnn[geneAnn$dev_geno >= thr_reliableGenes[1],]
geneAnn <- geneAnn[geneAnn$test_dev_geno > thr_reliableGenes[2],]

gene_list <- read.table(gene_list, h=F, stringsAsFactors = F)$V1

######################
#### load Tscore #####
######################

tscoreMat <- fread(sprintf('%spredictedTscores.txt', inputFold), header = T, stringsAsFactors = F, sep = '\t', check.names = F, data.table = F)
genesID <- tscoreMat[,1]
tscoreMat <- tscoreMat[,-1]
samplesID <- sapply(colnames(tscoreMat), function(x) strsplit(x, split = '.vs')[[1]][1])
samplesID <- unname(samplesID)
colnames(tscoreMat) <- samplesID
print(identical(samplesID, sampleAnn$Individual_ID))
tscoreMat <- t(tscoreMat) # samples on the rows

# remove sample that have NAs
id_s <- rowSums(is.na(tscoreMat)) == 0
sampleAnn <- sampleAnn[id_s,]
samplesID_new <- sampleAnn$Individual_ID
tscoreMat <- tscoreMat[id_s, ]

# filter geneAnn
if(!identical(genesID, geneAnn$external_gene_name)){
  print('adjust genes annotation')
  id <- sapply(genesID, function(x) which(x == geneAnn$external_gene_name))
  geneAnn <- geneAnn[id,]
}

print(paste('same gene annotation:', identical(geneAnn$external_gene_name, genesID)))

tscoreMat <- tscoreMat[,match(gene_list,genesID)]
colnames(tscoreMat) <- gene_list
geneAnn <- geneAnn[match(gene_list, geneAnn$external_gene_name), ]

print('Tscore mat loaded')

cor_mat <- cor(tscoreMat)
cor_mat_sp <- cor(tscoreMat, method = 'spearman')

# save
res <- list(geneAnn = geneAnn, cor = cor_mat, cor_spear = cor_mat_sp)

  # save results
filename <- sprintf('%scor_custom_geneList_%s.RData', outFold, geneSetName)
save(res, file = filename)


  

