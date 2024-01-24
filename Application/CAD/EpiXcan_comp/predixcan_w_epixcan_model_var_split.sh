#!/bin/bash

#SBATCH --job-name=predexp
#SBATCH --output=out/%x/%x_%a_%A.out
#SBATCH --error=err/%x/%x_%a_%A.err

#SBATCH --partition=normal
#SBATCH --time=01:30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G


module load palma/2020a GCC/9.3.0 OpenMPI/4.0.3 Python/2.7.18 SciPy-bundle/2020.03-Python-2.7.18


l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan
c=/cloud/wwu1/h_fungenpsy/AGZiller_data/EpiXcan/PredictDB
p=~/tools/PrediXcan/Software


python ${p}/PrediXcan.py \
  --predict \
  --dosages "${l}/data/ukbb/split${SLURM_ARRAY_TASK_ID}/" \
  --dosages_prefix chr \
  --samples "split${SLURM_ARRAY_TASK_ID}_samples.txt" \
  --weights "${c}/GTEx_Liv_EpiX_alpha0.5_window1e6_filtered.db" \
  --output_prefix "${l}/results/predexp/split${SLURM_ARRAY_TASK_ID}"

gzip "${l}/results/predexp/split${SLURM_ARRAY_TASK_ID}_predicted_expression.txt"