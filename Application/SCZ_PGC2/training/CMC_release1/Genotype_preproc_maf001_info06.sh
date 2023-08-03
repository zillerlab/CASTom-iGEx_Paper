#!/bin/bash
#SBATCH --job-name=geno
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/preProc_geno_maf001_info06_chr%a_%A.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/preProc_geno_maf001_info06_chr%a_%A.err
#SBATCH --mem-per-cpu=7G
#SBATCH -c 1
#SBATCH -p pe

module load R/3.5.3 

Rscript preProcess_genotype_maf001_info06_run.R \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/ \
    --pathGeno /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/ \
    --nameGeno filtered_chr_corRefAlt \
    --nameGWAS /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/PGC/Original_SCZ_variants_chr.txt \
    --pathInfo /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/ \
    --curChrom chr${SLURM_ARRAY_TASK_ID} 



