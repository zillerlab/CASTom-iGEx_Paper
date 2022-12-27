#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/ann_regSNPs_with_gwas.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/ann_regSNPs_with_gwas.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=40G

module load R/3.5.3

Rscript annotate_regSNPs_with_gwas_summ.R

