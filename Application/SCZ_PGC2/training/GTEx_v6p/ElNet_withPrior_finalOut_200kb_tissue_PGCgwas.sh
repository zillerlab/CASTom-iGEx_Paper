#!/bin/bash

t=$1
f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/
priorInd=$(awk '{print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/priorName_PGCgwas_withIndex.txt)

${git_fold}Software/model_training/PriLer_finalOutput_run.R \
    --covDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/200kb/PGC_GWAS_bin1e-2/ \
    --InfoFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/ \
    --functR ${git_fold}Software/model_training/PriLer_functions_run.R \
    --part1Res_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/200kb/ \
    --part2Res_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/200kb/PGC_GWAS_bin1e-2/ \
    --part3Res_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/200kb/PGC_GWAS_bin1e-2/ \
    --part4Res_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/200kb/PGC_GWAS_bin1e-2/ \
    --priorDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/priorMatrix_ \
    --priorInf ${priorInd[@]}  

 




