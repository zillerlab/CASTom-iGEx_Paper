#!/bin/bash

#SBATCH --job-name=clusrelp
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=6G

# Source: Application/CAD/clustering/PriLer_cluster_tscore_corrPCs_featureRelPath_GTEx_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results/ukbb
g=~/tools/castom-igex/Software/model_clustering


${g}/cluster_associatePath_corrPCs_run.R \
  --inputFold "${l}/" \
  --sampleAnnFile "${c}/Covariates/UKBB/CAD_HARD_clustering/covariateMatrix_CADHARD_All_phenoAssoc.txt" \
  --pvalresFile "${l}/pval_CAD_pheno_covCorr.RData" \
  --pval_id 1 \
  --type_cluster Cases \
  --outFold "${l}/CAD_HARD_clustering/update_corrPCs/" \
  --functR "${g}/clustering_functions.R" \
  --type_input zscaled \
  --clusterFile "${l}/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData" \
  --type_data_cluster tscore \
  --ncores 8 \
  --tissues Liver