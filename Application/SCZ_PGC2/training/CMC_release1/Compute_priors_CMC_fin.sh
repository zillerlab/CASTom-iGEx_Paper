#!/bin/bash
#SBATCH --job-name=prior
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/prior_SCZ-PGC_chr%a_%A.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/prior_SCZ-PGC_chr%a_%A.err
#SBATCH --mem-per-cpu=7G
#SBATCH -c 1
#SBATCH -p pe


Rscript ./Compute_priors_CMC_fin_run.R \
    --inputDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/ \
    --VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/Genotype_VariantsInfo_maf001_info06_CMC-PGCgwas-SCZ-PGCall_ \
    --chr ${SLURM_ARRAY_TASK_ID} 



