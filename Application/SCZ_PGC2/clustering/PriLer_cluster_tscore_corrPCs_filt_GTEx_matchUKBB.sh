#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_GTEx_t%a_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_GTEx_t%a_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=90G
#SBATCH -t 120:00:00

module load 2019
module load R/3.5.1-intel-2019b

cd /home/luciat/eQTL_PROJECT/

readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names_CLUST
name_cohorts=${cohorts[@]}

readarray -t tissues < /home/luciat/eQTL_PROJECT/OUTPUT_GTEx/Tissue_PGCgwas_red
id=${SLURM_ARRAY_TASK_ID}
t=$(eval echo "\${tissues[${id}-1]}")

input_file=()
cov_file=()
git_fold=/home/luciat/castom-igex/Software/model_clustering/

mkdir -p ${TMPDIR}/tmp_GTEx_tscore_t${id}_f/
cp OUTPUT_all/Meta_Analysis_SCZ/${t}/pval_Dx_pheno_covCorr.RData ${TMPDIR}/tmp_GTEx_tscore_t${id}_f/
cp OUTPUT_all/matchUKBB_samples_to_remove_outliersUMAP_tscore_corrPCs_zscaled_clusterCases.txt ${TMPDIR}/tmp_GTEx_tscore_t${id}_f/

for c in ${name_cohorts[@]}
do
	echo ${c}
   	mkdir -p ${TMPDIR}/tmp_GTEx_tscore_t${id}_f/${c}
	cp OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt ${TMPDIR}/tmp_GTEx_tscore_t${id}_f/${c}/
	input_file+=(${TMPDIR}/tmp_GTEx_tscore_t${id}_f/${c}/predictedTscores.txt)
	cov_file+=(INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt)
done

Rscript ${git_fold}cluster_PGmethod_corrPCs_multipleCohorts_run.R \
	--tissues_name ${t} \
	--inputFile ${input_file[@]} \
	--name_cohorts ${name_cohorts[@]} \
	--type_cluster Cases \
	--pvalresFile ${TMPDIR}/tmp_GTEx_tscore_t${id}_f/pval_Dx_pheno_covCorr.RData \
	--sampleAnnFile ${cov_file[@]} \
	--pval_id 1 \
	--type_data tscore \
	--corr_thr 0.1 \
	--type_input zscaled \
	--sampleOutFile ${TMPDIR}/tmp_GTEx_tscore_t${id}_f/matchUKBB_samples_to_remove_outliersUMAP_tscore_corrPCs_zscaled_clusterCases.txt \
	--outFold ${TMPDIR}/tmp_GTEx_tscore_t${id}_f/matchUKBB_filt0.1_ \
	--functR ${git_fold}clustering_functions.R \
	--genes_to_filter compare_prediction_UKBB_SCZ-PGC/${t}_filter_genes_matched_datasets.txt

cp ${TMPDIR}/tmp_GTEx_tscore_t${id}_f/matchUKBB_filt0.1*corrPCs*cluster* OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

rm -r ${TMPDIR}/tmp_GTEx_tscore_t${id}_f/

