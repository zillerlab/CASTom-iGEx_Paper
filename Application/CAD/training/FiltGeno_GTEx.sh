#!/usr/bin/sh

f=/psycl/g/mpsziller/lucia/

cp ${f}CAD/eQTL_PROJECT/INPUT_DATA_GTEx/GTEX_v6/Genotyping_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas_chr* ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/

Rscript ${f}FiltGeno_GTEx_run.R \
    --curChrom $1 \
    --infoInput_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_ \
    --infomatchInput_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-CADall-UKBB_ \
    --dosageInput_fold ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/ \
    --outFold ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/
