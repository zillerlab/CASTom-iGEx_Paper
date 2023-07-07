#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/corr_predVSreal_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/corr_predVSreal_%j.err
#SBATCH --mem-per-cpu=20G
#SBATCH -c 1
#SBATCH -p gpu


Rscript correlation_predictionAll_type.R
