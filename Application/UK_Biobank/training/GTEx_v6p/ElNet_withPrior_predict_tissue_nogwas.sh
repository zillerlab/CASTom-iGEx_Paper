#!/bin/bash

t=$1

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
geno_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchUKBB/Genotype_data/
cov_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/
fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/

mkdir -p ${fold}200kb/noGWAS/predict/

${git_fold}PriLer_predictGeneExp_run.R \
    --genoDat_file ${geno_fold}Genotype_dosage_ \
    --covDat_file ${cov_fold}covariates_EuropeanSamples.txt \
    --outFold ${fold}200kb/noGWAS/predict/ \
    --outTrain_fold ${fold}200kb/noGWAS/ \
    --InfoFold ${fold}
