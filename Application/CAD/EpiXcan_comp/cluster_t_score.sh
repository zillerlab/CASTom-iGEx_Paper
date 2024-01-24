#!/bin/bash

#SBATCH --job-name=clustsco
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=12G

# Source: Application/CAD/clustering/PriLer_cluster_tscore_corrPCs_GTEx_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results/ukbb
g=~/tools/castom-igex/Software/model_clustering


mkdir -p "${l}/CAD_HARD_clustering/update_corrPCs/"

${g}/cluster_PGmethod_corrPCs_run.R \
  --inputFile "${l}/predictedTscores_splitGenes" \
  --sampleAnnFile "${c}/Covariates/UKBB/CAD_HARD_clustering/covariateMatrix_CADHARD_All.txt" \
  --split_tot 100 \
  --pvalresFile "${l}/pval_CAD_pheno_covCorr.RData" \
  --pval_id 1 \
  --min_genes_path 2 \
  --type_data tscore \
  --type_cluster Cases \
  --outFold "${l}/CAD_HARD_clustering/update_corrPCs/" \
  --functR ${g}/clustering_functions.R \
  --corr_thr 0.9 \
  --type_input zscaled \
  --kNN_par 20 \
  --tissues_name Liver