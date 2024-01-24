#!/bin/bash

#SBATCH --job-name=clusents
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=12G

# Source: Application/CAD/clustering/PriLer_cluster_endophenotype_tscore_corrPCs_GTEx_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results/ukbb
g=~/tools/castom-igex


${g}/Software/model_clustering/cluster_associatePhenoGLM_run.R \
  --sampleAnnFile "${c}/Covariates/UKBB/CAD_HARD_clustering/covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt" \
  --phenoDatFile "${c}/Covariates/UKBB/CAD_HARD_clustering/phenotypeMatrix_CADHARD_All_phenoAssoc_withMedication.txt" \
  --phenoDescFile "${c}/Covariates/UKBB/CAD_HARD_clustering/phenotypeDescription_withMedication.txt" \
  --type_data tscore \
  --type_cluster Cases \
  --outFold "${l}/CAD_HARD_clustering/update_corrPCs/rescaleCont_withMedication_" \
  --functR "${g}/Software/model_clustering/clustering_functions.R" \
  --type_input corrPCs_zscaled \
  --type_sim HK \
  --clusterFile "${l}/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData" \
  --rescale_pheno T


${g}/Software/model_clustering/cluster_associatePhenoGLM_run.R \
  --sampleAnnFile "${c}/Covariates/UKBB/CAD_HARD_clustering/covariateMatrix_CADHARD_All_phenoAssoc.txt" \
  --phenoDatFile "${c}/Covariates/UKBB/CAD_HARD_clustering/phenotypeMatrix_CADHARD_All_phenoAssoc_withoutMedication.txt" \
  --phenoDescFile "${c}/Covariates/UKBB/CAD_HARD_clustering/phenotypeDescription_withoutMedication.txt" \
  --type_data tscore \
  --type_cluster Cases \
  --outFold "${l}/CAD_HARD_clustering/update_corrPCs/rescaleCont_withoutMedication_" \
  --functR "${g}/Software/model_clustering/clustering_functions.R" \
  --type_input corrPCs_zscaled \
  --type_sim HK \
  --clusterFile "${l}/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData" \
  --rescale_pheno T


${g}/Software/model_clustering/plot_endophenotype_grVSall_run.R \
  --type_cluster_data tscore \
  --type_cluster Cases \
  --type_input corrPCs_zscaled \
  --endopFile "${l}/CAD_HARD_clustering/update_corrPCs/rescaleCont_withMedication_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData" \
              "${l}/CAD_HARD_clustering/update_corrPCs/rescaleCont_withoutMedication_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData" \
  --outFold "${l}/CAD_HARD_clustering/update_corrPCs/" \
  --forest_plot T \
  --pval_pheno 0.001 \
  --colorFile "${g}/refData/color_pheno_type_UKBB.txt"