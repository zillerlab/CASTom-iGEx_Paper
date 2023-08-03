#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_cluster_tscore_corrPCs_zscaled_GLManalysis_%x_t%a_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_cluster_tscore_corrPCs_zscaled_GLManalysis_%x_t%a_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=30G
#SBATCH -t 24:00:00
#SBATCH -p normal


module load 2019
module load R/3.5.1-intel-2019b


cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_clustering/

readarray -t tissues < OUTPUT_GTEx/Tissue_PGCgwas_red
id=${SLURM_ARRAY_TASK_ID}
t=$(eval echo "\${tissues[${id}-1]}")

fold_UKBB=/home/luciat/UKBB_SCZrelated/

mkdir -p ${TMPDIR}/tmp_GTEx_t${id}/
fold_out=OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

cp ${fold_UKBB}/phenotypeDescription_rsSCZ.txt ${TMPDIR}/tmp_GTEx_t${id}/
cp ${fold_out}matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData ${TMPDIR}/tmp_GTEx_t${id}/
cp ${fold_out}matchUKBB_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz ${TMPDIR}/tmp_GTEx_t${id}/

clust_file=${TMPDIR}/tmp_GTEx_t${id}/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData

${git_fold}cluster_associatePhenoGLM_run.R \
	--phenoDatFile ${TMPDIR}/tmp_GTEx_t${id}/matchUKBB_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz \
	--phenoDescFile ${TMPDIR}/tmp_GTEx_t${id}/phenotypeDescription_rsSCZ.txt \
	--sampleAnnFile INPUT_DATA/Covariates/PCs_cluster/samples_PCs_clustering.txt \
	--clusterFile ${clust_file} \
	--type_cluster Cases \
	--functR ${git_fold}clustering_functions.R \
	--outFold ${TMPDIR}/tmp_GTEx_t${id}/matchUKBB_riskScores_ \
	--type_data tscore_corrPCs \
	--type_input zscaled \
	--risk_score T \
	--rescale_pheno T

cp ${TMPDIR}/tmp_GTEx_t${id}/matchUKBB_riskScores_*GLM* ${fold_out}
rm -r ${TMPDIR}/tmp_GTEx_t${id}/

