#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_originalRNA_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_originalRNA_%j.err
#SBATCH --mem-per-cpu=10MB
#SBATCH -c 1
#SBATCH -p hp

type_name=$1

# pathway analysis
jid1=$(sbatch --job-name=orRNA_${type_name}_path --parsable -c 1 --mem=20G ElNet_withPrior_path_orRNA.sh ${type_name})

