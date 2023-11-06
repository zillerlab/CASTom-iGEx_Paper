# subset samples to compute correlations for tscores and pathscores

sampleAnn <- read.table('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt', h=T, stringsAsFactors = F, sep = '\t')
sampleAnn <- sampleAnn[sampleAnn$Dx  == 0, ]

set.seed(23)
id <- sample(1:nrow(sampleAnn), size = 5000, replace = F)

new <- sampleAnn[sort(id), ]

write.table(new, file = '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_forCorrelation.txt', 
            col.names = T, row.names = F, quote = F, sep = '\t')
