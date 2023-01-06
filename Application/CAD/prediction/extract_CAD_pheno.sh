#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_CADrel_extract.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_CADrel_extract.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=100G

module load R/3.5.3

Rscript CAD_extract_pheno.R
