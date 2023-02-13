#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/risk_score_CAD_tscore_corrPCs_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/risk_score_CAD_tscore_corrPCs_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=90G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
fold_cl=${fold}CAD_HARD_clustering/update_corrPCs/

name_file=$(awk '{print $1}' INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/name_pheno_risk_score.txt)
name_file=(${name_file// / })
pval_file=()
for i in ${name_file[@]}
do
	pval_file+=(${fold}pval_${i}_pheno_covCorr.RData)
done


${git_fold}compute_risk_score_corrPCs_run.R \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW_202202.txt \
	--functR ${git_fold}clustering_functions.R \
	--outFold ${fold_cl} \
	--split_tot $1	\
	--inputFile ${fold}predictedTscores_splitGenes \
	--corrFile ${fold}correlation_estimate_tscore.RData \
	--type_data tscore \
	--sqcorr_thr 0.1 \
	--scale_rs T \
	--pvalresFile ${pval_file[@]} \
	--pheno_class_name ${name_file[@]}
