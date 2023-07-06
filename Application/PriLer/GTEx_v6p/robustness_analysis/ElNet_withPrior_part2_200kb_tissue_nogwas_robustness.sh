#!/bin/bash

t=$1
id=$2

mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/robustness_analysis/rep${id}/noGWAS/

outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/robustness_analysis/rep${id}/
covFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/robustness_analysis/
genFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/
rnaFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_training/

priorInd=$(awk '{print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_nogwas_withIndex.txt)

${git_fold}PriLer_part2_run.R --covDat_file ${covFold}covariates_EuropeanSamples_rep${id}.txt --genoDat_file ${genFold}Genotype_dosage_ --geneExp_file ${rnaFold}RNAseq_filt.txt --ncores 10 --outFold ${outFold}noGWAS/ --InfoFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/ --functR ${git_fold}PriLer_functions.R  --part1Res_fold ${outFold} --priorDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/priorMatrix_ --priorInf ${priorInd[@]} --E_set 2 2.25 2.5 2.75 3 3.25 3.5 3.75 4 5
