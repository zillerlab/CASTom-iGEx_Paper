#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/compareRes_TWAS_prediXcan_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/compareRes_TWAS_prediXcan_%j.err
#SBATCH --mem-per-cpu=20G
#SBATCH -c 1
#SBATCH -p gpu


Rscript CMC_compare_TWAS_prediXcan.R 
