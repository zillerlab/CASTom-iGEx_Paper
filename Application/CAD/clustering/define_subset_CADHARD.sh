#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/subset_samples_CADHARD.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/subset_samples_CADHARD.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=20G
#SBATCH --cpus-per-task=1


module load R/3.5.3

Rscript subset_samples_cl_CAD_HARD.R \
	--fold1 /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/ \
	--fold2 /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/

