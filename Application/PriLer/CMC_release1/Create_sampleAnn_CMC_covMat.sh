#!/bin/bash
#SBATCH --job-name=ann
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/sampleAnn_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/sampleAnn_%j.err
#SBATCH --mem-per-cpu=5G
#SBATCH -c 1
#SBATCH -p hp


Rscript SampleAnnotation_CMC_covMat_v2.R



