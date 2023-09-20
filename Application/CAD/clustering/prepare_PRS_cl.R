# create clusters based on PRS distributions
options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(dplyr))

setwd('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/')
PRS_res <- read.table("OUTPUT_GWAS/PRS/PRS_CAD_UKBB.best", h=T, stringsAsFactors = F)
PRS_res$PRS_scaled <- scale(PRS_res$PRS)[,1]
PRS_res$Individual_ID <- paste0("X", PRS_res$FID)

sampleAnn_file <- "INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/covariateMatrix_CADHARD_All.txt"
sampleAnn <- read.table(sampleAnn_file, h=T, stringsAsFactors = F, sep = "\t") %>%
    dplyr::filter(Dx == 1)
PRS_cases <- PRS_res[match(sampleAnn$Individual_ID, PRS_res$Individual_ID),]

# division into deciles
deciles_cases <- quantile(PRS_cases$PRS_scaled, probs = seq(0, 1, 0.1))
# divide PRS_res based on thresholds from deciles_cases
PRS_cases$PRS_decile <- cut(PRS_cases$PRS_scaled, breaks = deciles_cases, include.lowest = T)
# rename deciles
PRS_cases$PRS_decile_group <- as.numeric(PRS_cases$PRS_decile)
output <- list(samples_id = PRS_cases$Individual_ID, 
    cl_best = data.frame(id = PRS_cases$Individual_ID, gr = PRS_cases$PRS_decile_group))
save(output, file = "OUTPUT_GWAS/PRS/PRS_CAD_UKBB_Cases_deciles.RData")


# division into quantiles
quantiles_cases <- quantile(PRS_cases$PRS_scaled)
# divide PRS_res based on thresholds from quantiles_cases
PRS_cases$PRS_quantile <- cut(PRS_cases$PRS_scaled, breaks = quantiles_cases, include.lowest = T)
# rename quantiles
PRS_cases$PRS_quantile_group <- as.numeric(PRS_cases$PRS_quantile)
output <- list(samples_id = PRS_cases$Individual_ID, 
    cl_best = data.frame(id = PRS_cases$Individual_ID, gr = PRS_cases$PRS_quantile_group))
save(output, file = "OUTPUT_GWAS/PRS/PRS_CAD_UKBB_Cases_quantiles.RData")

# save
write.table(file = "OUTPUT_GWAS/PRS/PRS_CAD_UKBB_Cases_groups.txt", 
    x = PRS_cases, sep = "\t", quote = F, col.names = T, row.names = F)

