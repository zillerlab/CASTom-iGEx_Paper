#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_tscore_corrPCs_%x_t%a_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_tscore_corrPCs_%x_t%a_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=90G
#SBATCH -t 120:00:00


module load 2019
module load R/3.5.1-intel-2019b

cd /home/luciat/eQTL_PROJECT/

readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
name_cohorts=${cohorts[@]}

readarray -t tissues < OUTPUT_GTEx/Tissue_PGCgwas_red
id=${SLURM_ARRAY_TASK_ID}
t=$(eval echo "\${tissues[${id}-1]}")

fold_UKBB=/home/luciat/UKBB_SCZrelated/${t}/
fold_comp=compare_prediction_UKBB_SCZ-PGC/

mkdir -p ${TMPDIR}/tmp_GTEx_t${id}/
cp ${fold_UKBB}/* ${TMPDIR}/tmp_GTEx_t${id}/

name_file=$(awk '{print $1}' /home/luciat/UKBB_SCZrelated/name_pheno_risk_score.txt)
name_file=(${name_file// / })
pval_file=()
for i in ${name_file[@]}
do
	pval_file+=(${TMPDIR}/tmp_GTEx_t${id}/pval_${i}_pheno_covCorr.RData)
done

input_file=()
cov_file=()
git_fold=/home/luciat/castom-igex/Software/model_clustering/

for c in ${name_cohorts[@]}
do
	echo ${c}
   	mkdir -p ${TMPDIR}/tmp_GTEx_t${id}/${c}
	cp OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt ${TMPDIR}/tmp_GTEx_t${id}/${c}/
	input_file+=(${TMPDIR}/tmp_GTEx_t${id}/${c}/predictedTscores.txt)
	cov_file+=(INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt)
done

thr=$1
./${git_fold}compute_risk_score_corrPCs_multipleCohorts_run.R \
	--cases_only T \
	--scale_rs T \
	--pheno_class_name ${name_file[@]} \
	--corrFile ${TMPDIR}/tmp_GTEx_t${id}/correlation_estimate_tscore.RData \
	--inputFile ${input_file[@]} \
	--name_cohorts ${name_cohorts[@]} \
	--pvalresFile  ${pval_file[@]} \
	--sampleAnn_file ${cov_file[@]} \
	--type_data tscore \
	--sqcorr_thr 0.1 \
	--outFold ${TMPDIR}/tmp_GTEx_t${id}/matchUKBB_ \
	--functR ${git_fold}clustering_functions.R \
	--genes_to_filter compare_prediction_UKBB_SCZ-PGC/${t}_filter_genes_matched_datasets.txt

# compress output
cd ${TMPDIR}/tmp_GTEx_t${id}/
gzip matchUKBB_*risk_score_relatedPhenotypes.txt
cd /home/luciat/eQTL_PROJECT/

cp ${TMPDIR}/tmp_GTEx_t${id}/matchUKBB_*risk_score* OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

rm -r ${TMPDIR}/tmp_GTEx_t${id}/


