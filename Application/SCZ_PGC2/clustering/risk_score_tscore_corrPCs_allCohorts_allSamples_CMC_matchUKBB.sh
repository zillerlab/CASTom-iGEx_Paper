#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_all_tscore_corrPCs_zscaled_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_all_tscore_corrPCs_zscaled_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=100G
#SBATCH -t 24:00:00
#SBATCH -p fat

module load 2019
module load R/3.5.1-intel-2019b

cd /home/luciat/eQTL_PROJECT/

readarray -t cohorts < INPUT_DATA/SCZ_cohort_names
name_cohorts=${cohorts[@]}

fold_UKBB=/home/luciat/UKBB_SCZrelated/DLPC_CMC/
fold_comp=compare_prediction_UKBB_SCZ-PGC/

mkdir -p ${TMPDIR}/tmp_CMC_t
cp ${fold_UKBB}/* ${TMPDIR}/tmp_CMC_t/

name_file=$(awk '{print $1}' /home/luciat/UKBB_SCZrelated/name_pheno_risk_score_complete.txt)
name_file=(${name_file// / })
pval_file=()
for i in ${name_file[@]}
do
	pval_file+=(${TMPDIR}/tmp_CMC_t/pval_${i}_pheno_covCorr.RData)
done

input_file=()
cov_file=()
git_fold=/home/luciat/castom-igex/Software/model_clustering/

for c in ${name_cohorts[@]}
do
	echo ${c}
   	mkdir -p ${TMPDIR}/tmp_CMC_t/${c}
	cp OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt ${TMPDIR}/tmp_CMC_t/${c}/
	input_file+=(${TMPDIR}/tmp_CMC_t/${c}/predictedTscores.txt)
	cov_file+=(INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt)
done

${git_fold}compute_risk_score_corrPCs_multipleCohorts_run.R \
	--scale_rs T \
	--pheno_class_name ${name_file[@]} \
	--corrFile ${TMPDIR}/tmp_CMC_t/correlation_estimate_tscore.RData \
	--inputFile ${input_file[@]} \
	--name_cohorts ${name_cohorts[@]} \
	--pvalresFile  ${pval_file[@]} \
	--sampleAnn_file ${cov_file[@]} \
	--type_data tscore \
	--sqcorr_thr 0.1 \
	--outFold ${TMPDIR}/tmp_CMC_t/matchUKBB_allSamples_ \
	--functR ${git_fold}clustering_functions.R \
	--genes_to_filter compare_prediction_UKBB_SCZ-PGC/DLPC_CMC_filter_genes_matched_datasets.txt

# compress output
cd ${TMPDIR}/tmp_CMC_t/
gzip matchUKBB_allSamples_*risk_score_relatedPhenotypes.txt
cd /home/luciat/eQTL_PROJECT/

cp ${TMPDIR}/tmp_CMC_t/matchUKBB_allSamples_*risk_score* OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

rm -r ${TMPDIR}/tmp_CMC_t/



