#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/create_randomCAD.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/create_randomCAD.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=2G

module load R/3.5.3

Rscript create_random_pheno_CADbased.R
