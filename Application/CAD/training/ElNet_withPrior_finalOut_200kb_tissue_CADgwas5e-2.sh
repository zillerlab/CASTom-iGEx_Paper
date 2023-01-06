#!/bin/bash

t=$1

priorInd=$(awk '{print $1}' /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas_withIndex.txt)
git_fold=/mnt/lucia/castom-igex/Software/model_training/

Rscript ${git_fold}PriLer_finalOutput_run.R --covDat_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt --outFold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --InfoFold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/ --functR /mnt/lucia/PriLer_PROJECT_GTEx/RSCRIPTS/SCRIPTS_v2/PriLer_functions.R  --part1Res_fold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/ --part2Res_fold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --part3Res_fold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --part4Res_fold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --priorDat_file /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_ --priorInf ${priorInd[@]}  

 




