#!/bin/bash
#SBATCH -o /psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/err_out_fold/find_unrel_key34217.out
#SBATCH -e /psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/err_out_fold/find_unrel_key34217.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=100G

module load R/3.5.3

Rscript find_largestset_unrelatedSamples.R

