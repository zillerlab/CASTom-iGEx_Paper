#!/bin/bash

#SBATCH --job-name=clusrelt
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=4G

# Source: Application/CAD/clustering/PriLer_cluster_tscore_corrPCs_featureRelTscore_GTEx_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results
g=~/tools/castom-igex/Software/model_clustering


${g}/cluster_associateFeat_corrPCs_run.R \
  --inputFile "${l}/ukbb/predictedTscores_splitGenes" \
  --sampleAnnFile "${c}/Covariates/UKBB/CAD_HARD_clustering/covariateMatrix_CADHARD_All_phenoAssoc.txt" \
  --split_tot 100 \
  --pvalresFile "${l}/ukbb/pval_CAD_pheno_covCorr.RData" \
  --geneInfoFile "${l}/predexp/split1_predicted_expression_fmt.txt.gz" \
  --pval_id 1 \
  --min_genes_path 2 \
  --type_data tscore \
  --type_cluster Cases \
  --outFold "${l}/ukbb/CAD_HARD_clustering/update_corrPCs/ClusterOriginal_" \
  --functR "${g}/clustering_functions.R" \
  --type_input zscaled \
  --clusterFile "${l}/ukbb/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData" \
  --type_data_cluster tscore \
  --ncores 12 \
  --tissues Liver \
  --pvalcorr_thr 0.01