#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/update_samples_2023.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/update_samples_2023.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=20G
#SBATCH --cpus-per-task=1


module load R/3.5.3
path=/psycl/g/mpsziller/lucia/

Rscript ../../../R/update_UKBBsamples_after_withdraw_run.R \
	--samplewithdraw_file ${path}UKBB/phenotype_data/w34217_20230425_sampleTOremove.csv \
	--covDat_file ${path}CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW_202202.txt \
	--string_name 202304 \
	--outFold ${path}CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/

