#!/bin/bash
#SBATCH --job-name=cov
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/preProc_cov_chr%a_%A.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/preProc_cov_chr%a_%A.err
#SBATCH --mem-per-cpu=5G
#SBATCH -c 1
#SBATCH -p hp


Rscript preProcess_covariates.R 



