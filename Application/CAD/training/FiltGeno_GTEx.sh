#!/usr/bin/sh

f=/psycl/g/mpsziller/lucia/

Rscript ${f}PriLer_PROJECT_GTEx/RSCRIPTS/FiltGeno_GTEx_run.R \
    --curChrom $1 \
    --infoInput_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_ \
    --infomatchInput_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-CADall-UKBB_ \
    --dosageInput_fold ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/ \
    --outFold ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/
