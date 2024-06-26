#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/annotate_phenosCADrelated.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/annotate_phenosCADrelated.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=20G

module load R/3.5.3

Rscript annotate_intersection_CADrelatedpheno.R
