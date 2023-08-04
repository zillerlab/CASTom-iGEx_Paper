#!/bin/bash

t=$1
f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/
priorInd=$(awk '{print $1}' /psycl/g/mpsziller/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/priorName_PGCgwas_withIndex.txt)

${git_fold}Software/model_training/PriLer_part2_run.R \
    --covDat_file /psycl/g/mpsziller/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
    --genoDat_file /psycl/g/mpsziller/lucia/eQTL_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/Genotype_data/Genotype_dosage_caucasian_maf001_info06_ \
    --geneExp_file /psycl/g/mpsziller/lucia/eQTL_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/RNAseq_data/${t}/RNAseq_filt.txt \
    --ncores 9 \
    --outFold /psycl/g/mpsziller/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/200kb/PGC_GWAS_bin1e-2/ \
    --InfoFold /psycl/g/mpsziller/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/ \
    --functR ${git_fold}Software/model_training/PriLer_functions_run.R \
    --part1Res_fold /psycl/g/mpsziller/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/200kb/ \
    --priorDat_file /psycl/g/mpsziller/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/priorMatrix_ \
    --priorInf ${priorInd[@]} \
    --E_set 9 10 11 12 13 14 15 16 17


