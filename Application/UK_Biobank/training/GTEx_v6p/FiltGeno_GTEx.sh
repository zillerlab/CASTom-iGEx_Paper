#!/usr/bin/sh

Rscript /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/RSCRIPTS/FiltGeno_GTEx_run.R --curChrom $1 --infoInput_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_ --infomatchInput_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchUKBB/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-UKBB_ --dosageInput_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/ --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchUKBB/Genotype_data/
