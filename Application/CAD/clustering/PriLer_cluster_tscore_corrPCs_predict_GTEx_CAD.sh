#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_predict_tscore_corrPCs_CAD_t%a_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_predict_tscore_corrPCs_CAD_t%a_%x.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem=50G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
name_cohort=$1

mkdir -p OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${name_cohort}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
fold_mod=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${name_cohort}/devgeno0.01_testdevgeno0/
cov_fold_mod=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/${name_cohort}/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

${git_fold}cluster_PGmethod_corrPCs_predict_run.R \
	--inputFile ${fold}predictedTscores.txt \
	--sampleAnn_file ${cov_fold_mod}covariateMatrix_CADHARD_All.txt \
	--sampleAnnNew_file ${cov_fold}covariateMatrix.txt \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold}CAD_HARD_clustering/update_corrPCs/ \
	--functR ${git_fold}clustering_functions.R \
	--type_input zscaled \
	--clustFile ${fold_mod}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData

