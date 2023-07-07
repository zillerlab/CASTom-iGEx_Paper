# correct original RNAseq for covariates or for the covariates coefficients model build for each train 

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(Matrix))

parser <- ArgumentParser(description="regress out covariates from gene expression")

parser$add_argument("--regCoeff_cov", type = "character", default = 'NA', help = "regression coefficient for covariates build from a training model, if NA the RNA corrected for covariates only")
parser$add_argument("--exprDir", type = "character", help = "directory with gene expression")
parser$add_argument("--covFile", type = "character", default = 'NULL', help = "file with covariates")
parser$add_argument("--Dx", type = "logical", default = FALSE, help = "if true, Dx included as covariate")
parser$add_argument("--outFold", type="character", help = "Output file [basename only]")

args <- parser$parse_args()
regCoeff_cov <- args$regCoeff_cov
exprDir <- args$exprDir
covFile <- args$covFile
Dx <- args$Dx
outFold <- args$outFold

# ####################################################################
# # regCoeff_cov <- 'NA'
# regCoeff_cov <- '/ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/train_Control50/200kb/resPrior_regCoeffCov_allchr.txt'
# Dx <- F
# exprDir = '/ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/RNAseq_data/EXCLUDE_ANCESTRY_SVA/'
# covFile = '/ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt'
# outFold <- '/ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/no_train/'
# ####################################################################

# load entire matrix
expDat <- read.table(sprintf('%s/RNAseq_filt.txt', exprDir), header = T, stringsAsFactors = F, sep = '\t')
covDat <- read.table(covFile, header = T, stringsAsFactors = F)
sampleAnn <- covDat[, colnames(covDat) %in% c('Individual_ID', 'genoSample_ID', 'RNASample_ID')]

if(!Dx){col_exclude <- c('Individual_ID', 'genoSample_ID', 'RNASample_ID', 'Dx')}
covDat <- covDat[, !colnames(covDat) %in% col_exclude]

gene_ann <- expDat[, colnames(expDat) %in% c('type',	'chrom', 'TSS_start','TSS_end','name','start_position','end_position','ensembl_gene_id','external_gene_name')]
expDat <- expDat[, ! colnames(expDat) %in% c('type',	'chrom', 'TSS_start','TSS_end','name','start_position','end_position','ensembl_gene_id','external_gene_name')]
# order based on sample ann
id <- unname(sapply(sampleAnn$RNASample_ID, function(x) which(x == colnames(expDat))))
expDat <- expDat[, id]
# substitute rna names with individual names
colnames(expDat) <- sampleAnn$Individual_ID

# for each gene regress aout ancestry
expDat_tab <- t(expDat)
N <- ncol(expDat_tab)
new_expDat <- matrix(ncol = N, nrow = nrow(expDat_tab))

if(regCoeff_cov != 'NA'){
  
  regCoeff <- read.table(regCoeff_cov, header = T, stringsAsFactors = F)
  intercept <- regCoeff[, 'intercept']
  cov_coeff <- regCoeff[, colnames(covDat)]
  for(i in 1:N){
    if(i%%100 == 0){print(i)}
    new_expDat[,i] <- expDat_tab[,i] - intercept[i] - as.matrix(covDat) %*% t(cov_coeff[i,])
  }
  
}else{
  
  for(i in 1:N){
    
    if(i%%100 == 0){print(i)}
    
    cov_mod <- cbind(expDat_tab[,i], covDat)
    fit_cov <- lm(cov_mod[,1]~as.matrix(cov_mod[,-1]))
    new_expDat[,i]  <- expDat_tab[,i] - predict(fit_cov, newdata = cov_mod[,-1])  
    
  }
  
  
}

new_expDat <- t(new_expDat)
colnames(new_expDat) <- colnames(expDat)
new_expDat <- cbind(gene_ann, new_expDat)

# save result
write.table(new_expDat, file = sprintf('%s/RNAseq_filt_covCorrected.txt', outFold), sep = '\t', col.names = T, row.names = F, quote = F)



