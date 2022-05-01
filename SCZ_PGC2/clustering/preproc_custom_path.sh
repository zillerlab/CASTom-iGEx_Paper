#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/preproc_custom_path.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/preproc_custom_path.err
#SBATCH -N 1
#SBATCH --mem=5G
#SBATCH -t 48:00:00

module load pre2019 2019
module load R

Rscript /home/luciat/eQTL_PROJECT/RSCRIPTS/preProcess_customPath.R
