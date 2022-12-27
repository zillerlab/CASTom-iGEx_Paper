#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/create_genesets_locus.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/create_genesets_locus.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=2G

module load R/3.5.3

Rscript create_genesets_locus_WB.R
