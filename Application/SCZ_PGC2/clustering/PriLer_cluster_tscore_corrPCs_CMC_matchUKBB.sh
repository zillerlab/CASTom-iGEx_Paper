#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=90G
#SBATCH -p fat
#SBATCH -t 120:00:00
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2


module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/

cd ${HOME}/eQTL_PROJECT
readarray -t name_cohorts < INPUT_DATA/SCZ_cohort_names_CLUST
# copy TWAS res and outliers
cp OUTPUT_all/Meta_Analysis_SCZ/DLPC_CMC/pval_Dx_pheno_covCorr.RData ${TMPDIR}/
cp OUTPUT_all/clustering_res_matchUKBB_corrPCs/matchUKBB_samples_to_remove_outliersUMAP_tscore_corrPCs_zscaled_clusterCases.txt ${TMPDIR}/

# point to tscores and sample annotation files
s_sh=/scratch-shared/luciat/
input_file=()
cov_file=()

for c in ${name_cohorts[@]}
do
	input_file+=(${s_sh}/OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt)
	cov_file+=(INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt)
done

${git_fold}cluster_PGmethod_corrPCs_multipleCohorts_run.R \
	--tissues_name DLPC_CMC \
	--inputFile ${input_file[@]} \
	--name_cohorts ${name_cohorts[@]} \
	--type_cluster Cases \
	--pvalresFile ${TMPDIR}/pval_Dx_pheno_covCorr.RData \
	--sampleAnnFile ${cov_file[@]} \
	--pval_id 1 \
	--type_data tscore \
	--corr_thr 0.9 \
	--type_input zscaled \
	--outFold ${TMPDIR}/matchUKBB_ \
	--functR ${git_fold}clustering_functions.R \
	--sampleOutFile ${TMPDIR}/matchUKBB_samples_to_remove_outliersUMAP_tscore_corrPCs_zscaled_clusterCases.txt \
	--genes_to_filter compare_prediction_UKBB_SCZ-PGC/DLPC_CMC_filter_genes_matched_datasets.txt

cp ${TMPDIR}/matchUKBB*corrPCs*cluster* OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/



