#!/bin/bash

t=Brain_Cortex
rep=$1

priorInd=$(awk '{print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2_randomGWAS/rep${rep}/priorName_PGCgwas_withIndex.txt)
f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/Software/model_training/

${git_fold}PriLer_part3_run.R  --covDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt --genoDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_dosage_ --geneExp_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/RNAseq_filt.txt --ncores 30 --part2Res_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2_randomGWAS/rep${rep}/ --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2_randomGWAS/rep${rep}/ --InfoFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/ --functR ${git_fold}PriLer_functions.R --priorDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/priorMatrix_random_Ctrl_150_allPeaks_allRanger_heart_left_ventricle_GWAS_withRep_ --priorInf ${priorInd[@]} 

