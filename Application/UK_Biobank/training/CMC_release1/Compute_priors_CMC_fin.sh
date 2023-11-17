#!/bin/bash
#SBATCH --job-name=prior
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/prior_UKBB_chr%a_%A.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/prior_UKBB_chr%a_%A.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p hp


Rscript Compute_priors_CMC_fin_run.R \
    --inputDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_UKBB_SCRIPTS_v2/ \
    --VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchUKBB/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-UKBB_ \
    --chr ${SLURM_ARRAY_TASK_ID} 



