options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(dplyr))

# Parse arguments
parser <- ArgumentParser(description = "Prepare cluster specific pheno")
parser$add_argument("--clusterFile", type = "character", help = "file with clustering structure")
parser$add_argument("--sampleAnnFile", type = "character", help = "file with samples to be used")
parser$add_argument("--phenoDatFile_CADHARD", type = "character", help = "file with CAD pheno")
parser$add_argument("--outFold", type="character", help = "Output file [basename only]")

args <- parser$parse_args()
clusterFile <- args$clusterFile
sampleAnnFile <- args$sampleAnnFile
phenoDatFile_CADHARD <- args$phenoDatFile_CADHARD
outFold <- args$outFold

#########
# clusterFile <- "CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData"
# sampleAnnFile <- "CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW_202304.txt"
# phenoDatFile_CADHARD <- 'CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenoMatrix.txt'
# outFold <- paste0("CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/",
#  "/cluster_specific_PALAS/")
#########

cl_res <- get(load(clusterFile))
cl <- cl_res$cl_best
sampleAnn <- read.table(sampleAnnFile, header=T, sep="\t", stringsAsFactors=F)
phenoDat_CAD <- read.table(phenoDatFile_CADHARD, header=T, sep="\t", stringsAsFactors=F)
phenoDat_CAD <- phenoDat_CAD[match(sampleAnn$Individual_ID, phenoDat_CAD$Individual_ID),]

phenoDat_cl <- data.frame(Individual_ID=phenoDat_CAD$Individual_ID)
cl_id <- sort(unique(cl$gr))
for(i in cl_id){
    cl_i <- rep(NA, nrow(phenoDat_cl))
    cl_i[phenoDat_CAD$CAD_HARD == 0] <- 0
    cl_i[phenoDat_CAD$Individual_ID %in% cl$id[cl$gr == i]] <- 1
    phenoDat_cl[,paste0("gr", i)] <- cl_i
}

# build phenotype description
phenoDesc <- data.frame(
    pheno_id = paste0("gr", cl_id), 
    FieldID = paste0("gr", cl_id, "_vs_controls"),  
    Field = paste0("gr", cl_id, "_vs_controls"),  
    Sexed = "Unisex", 
    original_type = "CAT_SINGLE", 
    transformed_type = "CAT_SINGLE_UNORDERED"
)
phenoDesc$nsamples <- sapply(paste0("gr", cl_id), function(x) sum(!is.na(phenoDat_cl[,x])))
phenoDesc$nsamples_T <- sapply(paste0("gr", cl_id), function(x) sum(!is.na(phenoDat_cl[,x]) & phenoDat_cl[,x] ==1))
phenoDesc$nsamples_F <- sapply(paste0("gr", cl_id), function(x) sum(!is.na(phenoDat_cl[,x]) & phenoDat_cl[,x] ==0))

# save output
write.table(phenoDat_cl, paste0(outFold, "phenoMatrix_clusterSpecific.txt"), row.names=F, col.names=T, quote=F, sep="\t")
write.table(phenoDesc, paste0(outFold, "phenotypeDescription_clusterSpecific.txt"), row.names=F, col.names=T, quote=F, sep="\t")
