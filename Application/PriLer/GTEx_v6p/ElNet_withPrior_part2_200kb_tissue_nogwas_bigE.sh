#!/bin/bash

t=$1
f=/psycl/g/mpsziller/lucia/
priorInd=$(awk '{print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_nogwas_withIndex.txt)
git_fold=${f}castom-igex/Software/model_training/

${git_fold}PriLer_part2_run.R \
    --covDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
    --genoDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_dosage_ \
    --geneExp_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/RNAseq_filt.txt \
    --ncores 15 \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/noGWAS/ \
    --InfoFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/ \
    --functR ${git_fold}PriLer_functions.R \
    --part1Res_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/ \
    --priorDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/priorMatrix_ \
    --priorInf ${priorInd[@]} \
    --E_set 14 15 16 17 18 19 20 21 22 23


