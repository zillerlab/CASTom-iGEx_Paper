#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_%j.err
#SBATCH --mem-per-cpu=10MB
#SBATCH -c 1
#SBATCH -p hp


type_name=(Control50 Control100 Control150 ControlAll All)

# no train model
sbatch --job-name notrain RNAseq_covCorr_notrain.sh

# all train model
for t in ${type_name[@]}; do sbatch --job-name train_${t} RNAseq_covCorr_train.sh ${t} & done
