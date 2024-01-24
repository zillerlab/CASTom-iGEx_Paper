#!/bin/bash

#SBATCH --output=out/%x_%a_%A.out
#SBATCH --error=err/%x_%a_%A.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=4G

# Source: Application/CAD/clustering/PriLer_cluster_tscore_corrPCs_featureRelPath_GTEx_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/OUTPUT_GTEx/predict_CAD
g=~/tools/castom-igex/Software/model_clustering


cohort=$1

readarray -t tissues < "${c}/Tissue_CADgwas_final"

t=$(eval echo "\${tissues[${SLURM_ARRAY_TASK_ID}-1]}")

inputFold=()
pvalresFile=()

for ts in ${tissues[@]}; do
  fold_t=${c}/${ts}/200kb/CAD_GWAS_bin5e-2/${cohort}/devgeno0.01_testdevgeno0
  inputFold+=(${fold_t}/)
  pvalresFile+=(${fold_t}/pval_CAD_pheno_covCorr.RData)
done


fold_cl="${c}/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs"


mkdir -p "${l}/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/"

${g}/cluster_associatePath_corrPCs_run.R \
  --inputFold ${inputFold[@]} \
  --sampleAnnFile "/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/${cohort}/covariateMatrix.txt" \
  --pvalresFile ${pvalresFile[@]} \
  --pval_id 1 \
  --type_cluster Cases \
  --outFold "${l}/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/" \
  --functR "${g}/clustering_functions.R" \
  --type_input zscaled \
  --clusterFile "${fold_cl}/tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData" \
  --type_data_cluster tscore \
  --ncores 6 \
  --tissues ${tissues[@]}