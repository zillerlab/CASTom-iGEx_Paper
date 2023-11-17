#!/bin/bash
#SBATCH --job-name=filt
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/filtGeno_UKBB_chr%a_%A.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/filtGeno_UKBB_chr%a_%A.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p hp


Rscript FiltGeno_CMC_run.R \
    --curChrom chr${SLURM_ARRAY_TASK_ID} \
    --infoInput_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/Genotype_VariantsInfo_CMC-PGC_ \
    --infomatchInput_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchUKBB/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-UKBB_ \
    --dosageInput_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/ \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchUKBB/Genotype_data/
