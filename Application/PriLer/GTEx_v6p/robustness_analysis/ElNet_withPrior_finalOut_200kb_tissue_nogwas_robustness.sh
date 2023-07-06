#!/bin/bash

t=$1
id=$2


outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/robustness_analysis/rep${id}/
covFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/robustness_analysis/
genFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/
rnaFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_training/

priorInd=$(awk '{print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_nogwas_withIndex.txt)


Rscript ${git_fold}PriLer_finalOutput_run.R --covDat_file ${covFold}covariates_EuropeanSamples_rep${id}.txt --outFold ${outFold}noGWAS/ --InfoFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/ --functR ${git_fold}PriLer_functions.R  --part1Res_fold ${outFold} --part2Res_fold ${outFold}noGWAS/ --part3Res_fold ${outFold}noGWAS/ --part4Res_fold ${outFold}/noGWAS/ --priorDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/priorMatrix_ --priorInf ${priorInd[@]}  


