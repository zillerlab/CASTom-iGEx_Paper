#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/compare_cl_corrPCs.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/compare_cl_corrPCs.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=40G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

Rscript compare_cl_corrPCs.R