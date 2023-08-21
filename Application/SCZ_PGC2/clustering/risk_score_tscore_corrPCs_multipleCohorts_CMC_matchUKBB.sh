#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_tscore_corrPCs_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_tscore_corrPCs_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=56G
#SBATCH -t 40:00:00


module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/
s_sh=/scratch-shared/luciat/

cd ${HOME}/eQTL_PROJECT/
readarray -t name_cohorts < INPUT_DATA/SCZ_cohort_names

fold_UKBB=${HOME}/UKBB_SCZrelated/DLPC_CMC/
fold_comp=compare_prediction_UKBB_SCZ-PGC/

cp ${fold_UKBB}/* ${TMPDIR}/

name_file=$(awk '{print $1}' ${HOME}/UKBB_SCZrelated/name_pheno_risk_score_complete.txt)
name_file=(${name_file// / })
pval_file=()
for i in ${name_file[@]}
do
	pval_file+=(${TMPDIR}/pval_${i}_pheno_covCorr.RData)
done

input_file=()
cov_file=()
for c in ${name_cohorts[@]}
do
	echo ${c}
	input_file+=(${s_sh}/OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt)
	cov_file+=(INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt)
done

${git_fold}compute_risk_score_corrPCs_multipleCohorts_run.R \
	--cases_only T \
	--scale_rs T \
	--pheno_class_name ${name_file[@]} \
	--corrFile ${TMPDIR}/correlation_estimate_tscore.RData \
	--inputFile ${input_file[@]} \
	--name_cohorts ${name_cohorts[@]} \
	--pvalresFile  ${pval_file[@]} \
	--sampleAnn_file ${cov_file[@]} \
	--type_data tscore \
	--sqcorr_thr 0.1 \
	--outFold ${TMPDIR}/matchUKBB_ \
	--functR ${git_fold}clustering_functions.R \
	--genes_to_filter compare_prediction_UKBB_SCZ-PGC/DLPC_CMC_filter_genes_matched_datasets.txt

# compress output
cd ${TMPDIR}/
gzip matchUKBB_*risk_score_relatedPhenotypes.txt
cd ${HOME}/eQTL_PROJECT/

cp ${TMPDIR}/matchUKBB_*risk_score* OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/



