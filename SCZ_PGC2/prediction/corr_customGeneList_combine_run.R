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
parser$add_argument("--corr_cohort", type = "character", nargs = '*', help = "correlation single cohorts")
parser$add_argument("--sampleAnn_file", type = "character", nargs = '*', help = "file with sample info for new genotype data, must contain Dx column (0 controls 1 cases)")
parser$add_argument("--geneSetName", type = "character", help = "name for saving")
parser$add_argument("--outFold", type="character", help = "Output file [basename only]")

args <- parser$parse_args()
corr_cohort <- args$corr_cohort
sampleAnn_file <- args$sampleAnn_file
geneSetName <- args$geneSetName
outFold <- args$outFold

##########################################################################################
# cohort_name <- read.table('INPUT_DATA/SCZ_cohort_names', h=F, stringsAsFactors=F)$V1
# corr_cohort <-  paste0('OUTPUT_CMC/predict_PGC/200kb/',cohort_name,'/devgeno0.01_testdevgeno0/cor_custom_geneList_SCZ_LoF_GeneSets.RData')
# outFold <- 'OUTPUT_CMC/predict_PGC/200kb/scz_ersw_eur/devgeno0.01_testdevgeno0/'
# sampleAnn_file <- paste0('INPUT_DATA/Covariates/',cohort_name,'.covariateMatrix_old.txt')
# ##########################################################################################

# load sample annotation
nc <- length(sampleAnn_file)
Neff <- vector(mode = 'numeric', length = nc)
cor_mat <- list()
cor_mat_sp <- list()

for(i in 1:nc){
  tmp <- read.table(sampleAnn_file[i], h=T, stringsAsFactors=F)
  Neff[i] <- 4/(1/sum(tmp$Dx==1) + 1/sum(tmp$Dx==0))
  cor_res <- get(load(corr_cohort[i]))
  
  cor_mat[[i]] <- sqrt(Neff[i])*cor_res$cor
  # cor_mat[[i]] <- cor_res$cor
  cor_mat_sp[[i]] <- sqrt(Neff[i])*cor_res$cor_spear
  # cor_mat_sp[[i]] <- cor_res$cor_spear
}

cor_tot <- Reduce('+', cor_mat)/length(cor_mat)
cor_tot <- cor_tot/diag(cor_tot)[1]

cor_tot_sp <- Reduce('+', cor_mat_sp)/length(cor_mat_sp)
cor_tot_sp <- cor_tot_sp/diag(cor_tot_sp)[1]

res <- list(Neff = Neff, cor = cor_tot, cor_spearman = cor_tot_sp, geneAnn = cor_res$geneAnn)
save(res, file = sprintf('%scor_custom_geneList_%s_combined.RData', outFold, geneSetName))


