#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/preProcess_CovFile.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/preProcess_CovFile.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=5G


Rscript preProcess_covariates.R
