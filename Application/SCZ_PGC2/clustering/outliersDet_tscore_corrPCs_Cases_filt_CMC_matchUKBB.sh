#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/detectOutliers_tscore_zscaled_CMC_filt0.1_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/detectOutliers_tscore_zscaled_CMC_filt0.1_matchUKBB.err
#SBATCH -N 1
#SBATCH -t 24:00:00
#SBATCH --mem=30G
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4


module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/

# copy TWAS res
cd ${HOME}/eQTL_PROJECT
mkdir -p OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/
cp OUTPUT_all/Meta_Analysis_SCZ/DLPC_CMC/pval_Dx_pheno_covCorr.RData ${TMPDIR}/
readarray -t name_cohorts < INPUT_DATA/SCZ_cohort_names_CLUST

s_sh=/scratch-shared/luciat/
input_file=()
cov_file=()

for c in ${name_cohorts[@]}
do
	input_file+=(${s_sh}/OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt)
	cov_file+=(INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt)
done

${git_fold}detect_outliers_corrPCs_multipleCohorts_run.R \
	--tissues_name DLPC_CMC \
	--inputFile ${input_file[@]} \
	--name_cohorts ${name_cohorts[@]} \
	--type_cluster Cases \
	--pvalresFile ${TMPDIR}/pval_Dx_pheno_covCorr.RData \
	--sampleAnnFile ${cov_file[@]} \
	--pval_id 1 \
	--type_data tscore \
	--corr_thr 0.1 \
	--type_input zscaled \
	--tissues_name DLPC_CMC \
	--outFold ${TMPDIR}/matchUKBB_filt0.1_ \
	--functR ${git_fold}clustering_functions.R \
	--min_genes_path 2 \
	--genes_to_filter compare_prediction_UKBB_SCZ-PGC/DLPC_CMC_filter_genes_matched_datasets.txt

cp ${TMPDIR}/matchUKBB_filt0.1_*cluster* OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/


