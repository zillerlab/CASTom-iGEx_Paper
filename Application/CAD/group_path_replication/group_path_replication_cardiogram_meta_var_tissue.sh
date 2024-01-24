#!/bin/bash

#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G

# Source: Application/CAD/clustering/PriLer_cluster_predictEval_tscore_corrPCs_GTEx_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/OUTPUT_GTEx/predict_CAD
g=~/tools/castom-igex/Software/model_clustering


t=$1

cohorts=(German1 German2 German3 German4 German5 CG WTCCC LURIC MG)


clus_pred=()
feat_rel=()

for cohort in ${cohorts[@]}; do
  clus_pred+=(${c}/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData)
  feat_rel+=(${l}/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/pathOriginal_filtJS0.2_corrPCs_tscoreClusterCases_featAssociation.RData)
done


mkdir -p "${l}/${t}/200kb/CAD_GWAS_bin5e-2/Meta_Analysis_CAD/CAD_HARD_clustering/update_corrPCs/"

${g}/cluster_predict_evaluate_run.R \
  --cohort_name ${cohorts[@]} \
  --functR ${g}/clustering_functions.R \
  --clustFile "${c}/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData" \
  --clustFile_new ${clus_pred[@]} \
  --type_data pathway \
  --type_cluster Cases \
  --type_input zscaled \
  --outFold "${l}/${t}/200kb/CAD_GWAS_bin5e-2/Meta_Analysis_CAD/CAD_HARD_clustering/update_corrPCs/" \
  --model_name UKBB \
  --featRel_predict ${feat_rel[@]} \
  --featRel_model "${c}/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/pathOriginal_filtJS0.2_corrPCs_tscoreClusterCases_featAssociation.RData"