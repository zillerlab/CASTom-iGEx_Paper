#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/prepare_CADCases_bootstrap.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/prepare_CADCases_bootstrap.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=100G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

cov_fold=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
Rscript prepare_bootstrap_run.R \
    --sampleAnnFile ${cov_fold}covariateMatrix_CADHARD_All.txt \
    --outFold ${cov_fold}bootstrap50/ \
    --n_rep 10 \
    --type_cluster Cases \
    --bootstrap_perc 50
