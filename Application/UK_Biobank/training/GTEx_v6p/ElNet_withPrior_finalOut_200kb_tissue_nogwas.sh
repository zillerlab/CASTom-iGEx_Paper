#!/bin/bash

t=$1

f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/Software/model_training/
priorInd=$(awk '{print $1}' ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/priorName_nogwas_withIndex.txt)

${git_fold}PriLer_finalOutput_run.R \ 
    --covDat_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
    --outFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/200kb/noGWAS/ \
    --InfoFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/ \
    --functR ${git_fold}PriLer_functions.R \
    --part1Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/200kb/ \
    --part2Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/200kb/noGWAS/ \
    --part3Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/200kb/noGWAS/ \
    --part4Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/200kb/noGWAS/ \
    --priorDat_file ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/priorMatrix_ \
    --priorInf ${priorInd[@]}  

 




