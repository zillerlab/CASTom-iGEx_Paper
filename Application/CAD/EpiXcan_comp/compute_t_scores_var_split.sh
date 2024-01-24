#!/bin/bash

#SBATCH --job-name=epitscor
#SBATCH --output=out/%x/%x_%a_%A.out
#SBATCH --error=err/%x/%x_%a_%A.err

#SBATCH --partition=normal
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=2G


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan
g=~/tools/castom-igex/Software/model_prediction


inputfile_list=()

for i in $(seq 100); do
  inputfile_list+=(${l}/results/predexp/split${i}_predicted_expression_fmt.txt.gz)
done


${g}/Tscore_splitGenes_run.R \
  --input_file ${inputfile_list[*]} \
  --nFolds 10 \
  --perc_comp 0.7 \
  --ncores 24 \
  --covDat_file "${c}/Covariates/UKBB/covariateMatrix_latestW_202304.txt" \
  --outFold "${l}/results/tscores/" \
  --split_gene_id ${SLURM_ARRAY_TASK_ID} \
  --split_tot 100