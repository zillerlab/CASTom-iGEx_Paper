#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/prepare_PRS_cl.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/prepare_PRS_cl.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

Rscript prepare_PRS_cl.R