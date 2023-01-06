#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predict_endopheno_diff_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predict_endopheno_diff_t%a.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem=30G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_SHIP/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < Tissues
t=$(eval echo "\${tissues[${id_t}-1]}")

cohort_name=SHIP-TREND
fold_cl=Results/PriLer/${t}/
fold_input=Results/PriLer/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

Rscript ${git_fold}cluster_predict_associatePhenoGLM_run.R \
	--cohort_name ${cohort_name} \
	--functR ${git_fold}clustering_functions.R \
	--clustFile_new ${fold_cl}tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData \
	--type_data tscore_corrPCs \
	--type_cluster Cases \
	--type_input zscaled \
	--outFold ${fold_cl}test_ \
	--model_name UKBB \
	--phenoNew_file ${fold_input}pheno_test.txt \
	--covNew_file ${fold_input}SHIP-TREND_gPC_SHIP_2022_27_withSex.txt
