#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/risk_score_tscore_corrPCs_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/risk_score_tscore_corrPCs_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=90G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/Tissue_noGWAS
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/
fold_out=${fold}/update_corrPCs/
mkdir -p ${fold_out}

name_file=$(awk '{print $1}' INPUT_DATA/Covariates/name_pheno_clusterSCZ.txt)
name_file=(${name_file// / })
pval_file=()
for i in ${name_file[@]}
do
	pval_file+=(${fold}pval_${i}_pheno_covCorr.RData)
done
fold_comp=/psycl/g/mpsziller/lucia/compare_prediction_UKBB_SCZ-PGC/

${git_fold}compute_risk_score_corrPCs_run.R \
	--genes_to_filter ${fold_comp}${t}_filter_genes_matched_datasets.txt \
	--sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix_red_latestW_202202.txt \
	--functR ${git_fold}clustering_functions.R \
	--outFold ${fold_out}matchPGC_ \
	--split_tot $1	\
	--inputFile ${fold}predictedTscores_splitGenes \
	--corrFile ${fold}correlation_estimate_tscore.RData \
	--type_data tscore \
	--sqcorr_thr 0.1 \
	--scale_rs T \
	--pvalresFile ${pval_file[@]} \
	--pheno_class_name ${name_file[@]}
