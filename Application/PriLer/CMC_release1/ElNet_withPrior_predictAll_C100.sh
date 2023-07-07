#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.err
#SBATCH --mem-per-cpu=10MB
#SBATCH -c 1
#SBATCH -p hp

type_name=$1

# predict
jid1=$(sbatch --job-name=${type_name}_pred --parsable -c 1 --mem=20G ElNet_withPrior_predExpr_200kb.sh ${type_name})

# pathway analysis
jid2=$(sbatch --job-name=${type_name}_path --parsable --dependency=afterany:$jid1 -c 1 --mem=20G ElNet_withPrior_path_200kb.sh ${type_name})
