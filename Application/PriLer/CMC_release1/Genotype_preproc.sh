#!/bin/bash
#SBATCH --job-name=geno
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/preProc_geno_chr%a_%A.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/preProc_geno_chr%a_%A.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p hp


Rscript preProcess_genotype_run.R --pathGeno /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/ --nameGeno filtered_chr_corRefAlt --nameGWAS /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/PGC/Original_SCZ_variants_chr.txt --pathInfo /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/ --curChrom chr${SLURM_ARRAY_TASK_ID} 



