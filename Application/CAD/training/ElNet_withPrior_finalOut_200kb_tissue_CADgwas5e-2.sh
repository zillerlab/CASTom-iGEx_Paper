#!/bin/bash

t=$1

f=/psycl/g/mpsziller/lucia/
priorInd=$(awk '{print $1}' ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas_withIndex.txt)
git_fold=${f}castom-igex/Software/model_training/

${git_fold}PriLer_finalOutput_run.R --covDat_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt --outFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --InfoFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/ --functR ${git_fold}PriLer_functions.R  --part1Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/ --part2Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --part3Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --part4Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --priorDat_file ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_ --priorInf ${priorInd[@]}  

 




