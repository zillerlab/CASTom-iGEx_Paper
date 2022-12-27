#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/prepare_covariate_for_GWAS.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/prepare_covariate_for_GWAS.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/castom_cad_scz/CAD/matched_GWAS/
Rscript prepare_files_GWAS.R

