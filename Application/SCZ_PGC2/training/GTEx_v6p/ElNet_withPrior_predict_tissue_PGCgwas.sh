#!/bin/bash

t=$1

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
geno_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/Genotype_data/
cov_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/
fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/

mkdir -p ${fold}200kb/PGC_GWAS_bin1e-2/predict/

${git_fold}ElNet_withPrior_predictGeneExp_run.R \
    --genoDat_file ${geno_fold}Genotype_dosage_caucasian_maf001_info06_ \
    --covDat_file ${cov_fold}covariates_EuropeanSamples.txt \
    --outFold ${fold}200kb/PGC_GWAS_bin1e-2/predict/ \
    --outTrain_fold ${fold}200kb/PGC_GWAS_bin1e-2/ \
    --InfoFold ${fold}

