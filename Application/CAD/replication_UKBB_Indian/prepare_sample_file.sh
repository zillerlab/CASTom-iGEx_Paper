#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/prepare_sample_indian.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/prepare_sample_indian.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=50G

module load R/3.5.3

fold=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB_other_ancestry/

# run CAD definition extraction across all samples
Rscript /psycl/g/mpsziller/lucia/castom_cad_scz/R/extract_CAD_pheno_from_UKBB.R \
	--outFold ${fold} \
	--phenoFold /psycl/g/mpsziller/lucia/UKBB/phenotype_data/

# filter indian ancestry and prepare input files
Rscript prepare_samples_other_ancestry.R \
	--outFold ${fold} \
	--phenoFold /psycl/g/mpsziller/lucia/UKBB/phenotype_data/ \
	--ancestry Indian \
	--latest_sample_rm /psycl/g/mpsziller/lucia/UKBB/phenotype_data/w34217_20220222_sampleTOremove.csv
