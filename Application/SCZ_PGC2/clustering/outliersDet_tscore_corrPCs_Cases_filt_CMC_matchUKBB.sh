#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/detectOutliers_tscore_zscaled_CMC_filt0.1_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/detectOutliers_tscore_zscaled_CMC_filt0.1_matchUKBB.err
#SBATCH -N 1
#SBATCH -t 24:00:00
#SBATCH --mem=40G


module load 2019
module load R/3.5.1-intel-2019b


cd /home/luciat/eQTL_PROJECT/

readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names_CLUST
name_cohorts=${cohorts[@]}

input_file=()
cov_file=()
git_fold=/home/luciat/castom-igex/Software/model_clustering/

mkdir -p ${TMPDIR}/tmp_CMC_t
cp OUTPUT_all/Meta_Analysis_SCZ/DLPC_CMC/pval_Dx_pheno_covCorr.RData ${TMPDIR}/tmp_CMC_t/

for c in ${name_cohorts[@]}
do
	echo ${c}
   	mkdir -p ${TMPDIR}/tmp_CMC_t/${c}
	cp OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt ${TMPDIR}/tmp_CMC_t/${c}/
	input_file+=(${TMPDIR}/tmp_CMC_t/${c}/predictedTscores.txt)
	cov_file+=(INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt)
done

thr=$1
Rscript ${git_fold}detect_outliers_corrPCs_multipleCohorts_run.R \
	--tissues_name DLPC_CMC \
	--inputFile ${input_file[@]} \
	--name_cohorts ${name_cohorts[@]} \
	--type_cluster Cases \
	--pvalresFile ${TMPDIR}/tmp_CMC_t/pval_Dx_pheno_covCorr.RData \
	--sampleAnnFile ${cov_file[@]} \
	--pval_id 1 \
	--type_data tscore \
	--corr_thr 0.1 \
	--type_input zscaled \
	--tissues_name DLPC_CMC \
	--outFold ${TMPDIR}/tmp_CMC_t/matchUKBB_filt0.1_ \
	--functR ${git_fold}clustering_functions.R \
	--min_genes_path 2 \
	--genes_to_filter compare_prediction_UKBB_SCZ-PGC/DLPC_CMC_filter_genes_matched_datasets.txt

cp ${TMPDIR}/tmp_CMC_t/matchUKBB_filt0.1_*cluster* OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

rm -r ${TMPDIR}/tmp_CMC_t/

