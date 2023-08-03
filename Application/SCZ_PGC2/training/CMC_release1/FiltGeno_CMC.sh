#!/bin/bash
#SBATCH --job-name=filt
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/filtGeno_SCZ-PGC_chr%a_%A.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/filtGeno_SCZ-PGC_chr%a_%A.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p pe


Rscript ./FiltGeno_CMC_run.R \
    --curChrom chr${SLURM_ARRAY_TASK_ID} \
    --infoInput_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/Genotype_VariantsInfo_caucasian_maf001_info06_CMC-PGC_ \
    --infomatchInput_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/Genotype_VariantsInfo_maf001_info06_CMC-PGCgwas-SCZ-PGCall_ \
    --dosageInput_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/Genotype_dosage_caucasian_maf001_info06_ \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/Genotype_dosage_caucasian_maf001_info06_
