#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoProc_UKBB.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoProc_UKBB.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=20G

module load R/3.5.3

# build CAD phenotype and UKBB covariate
Rscript preProcess_phenotype_CAD_UKBB.R

# add pheno description
Rscript preProcess_phenotype_CAD_UKBB_desc.R
