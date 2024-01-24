#!/bin/bash

#SBATCH --job-name=filtpajs
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=12G

# Source: Application/CAD/clustering/filter_pathway_JS.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results/ukbb
g=~/tools/castom-igex/Software/model_clustering


${g}/filter_pathway_jaccard_sim_run.R \
  --pvalresFile "${l}/pval_CAD_pheno_covCorr.RData" \
  --thr_js 0.2 \
  --outFold "${l}/"