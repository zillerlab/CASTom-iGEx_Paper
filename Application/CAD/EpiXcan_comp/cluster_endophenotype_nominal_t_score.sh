#!/bin/bash

#SBATCH --job-name=clusenno
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=12G

# Source: Application/CAD/clustering/PriLer_cluster_endophenotype_nominal_tscore_corrPCs_GTEx_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results/ukbb
g=~/tools/castom-igex/Software/model_clustering


${g}/cluster_associatePhenoGLM_run.R \
  --sampleAnnFile "${c}/Covariates/UKBB/CAD_HARD_clustering/covariateMatrix_CADHARD_All_phenoAssoc.txt" \
  --phenoDatFile "${c}/Covariates/UKBB/phenoMatrix_CADpheno_nominal.txt" \
  --phenoDescFile "${c}/Covariates/UKBB/phenotypeDescription_manualProc_CADpheno_nominal.txt" \
  --type_data tscore \
  --type_cluster Cases \
  --outFold "${l}/CAD_HARD_clustering/update_corrPCs/nominalAnalysis_" \
  --functR "${g}/clustering_functions.R" \
  --type_input corrPCs_zscaled \
  --type_sim HK \
  --clusterFile "${l}/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData"