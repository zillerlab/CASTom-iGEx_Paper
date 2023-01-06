#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/combine_GWAS_output.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/combine_GWAS_output.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load R/3.5.3

Rscript combine_gwas_output.R

