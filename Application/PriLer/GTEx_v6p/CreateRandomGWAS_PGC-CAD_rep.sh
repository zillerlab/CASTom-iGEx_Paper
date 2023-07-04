#!/bin/bash

chr=$1

Rscript CreateRandomGWAS_GTEx_rep_run.R  \
    --curChrom ${chr} \
    --VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_ \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/randomGWAS/ \
    --N_samples 45000 35000 \
    --n_rep 10


