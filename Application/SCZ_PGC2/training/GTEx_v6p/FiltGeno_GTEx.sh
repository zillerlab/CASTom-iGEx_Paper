#!/usr/bin/sh

Rscript ./FiltGeno_GTEx_run.R \
    --curChrom chr$1 \
    --infoInput_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_caucasian_maf001_info06_CMC-PGCgwas-CADgwas_ \
    --infomatchInput_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/Genotype_data/Genotype_VariantsInfo_maf001_info06_GTEx-PGCgwas-SCZ-PGCall_ \
    --dosageInput_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_dosage_caucasian_maf001_info06_ \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/Genotype_data/Genotype_dosage_caucasian_maf001_info06_
