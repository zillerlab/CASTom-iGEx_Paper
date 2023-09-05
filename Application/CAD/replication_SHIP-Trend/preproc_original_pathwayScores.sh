#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/preproc_original_pathwayScores.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/preproc_original_pathwayScores.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem=30G

module load R/3.5.3

Rscript preproc_original_pathwayScores.R

