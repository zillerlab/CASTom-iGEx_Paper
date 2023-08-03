#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_cluster_tscore_corrPCs_zscaled_GLManalysis_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_cluster_tscore_corrPCs_zscaled_GLManalysis_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=30G
#SBATCH -t 24:00:00
#SBATCH -p fat


module load 2019
module load R/3.5.1-intel-2019b


cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_clustering/

fold_UKBB=/home/luciat/UKBB_SCZrelated/

mkdir -p ${TMPDIR}/tmp_CMC/
fold_out=OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

cp ${fold_UKBB}/phenotypeDescription_rsSCZ_updated.txt ${TMPDIR}/tmp_CMC/
cp ${fold_out}matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData ${TMPDIR}/tmp_CMC/
cp ${fold_out}matchUKBB_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz ${TMPDIR}/tmp_CMC/

clust_file=${TMPDIR}/tmp_CMC/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData

${git_fold}cluster_associatePhenoGLM_run.R \
	--phenoDatFile ${TMPDIR}/tmp_CMC/matchUKBB_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz \
	--phenoDescFile ${TMPDIR}/tmp_CMC/phenotypeDescription_rsSCZ_updated.txt \
	--sampleAnnFile INPUT_DATA/Covariates/PCs_cluster/samples_PCs_clustering.txt \
	--clusterFile ${clust_file} \
	--type_cluster Cases \
	--functR ${git_fold}clustering_functions.R \
	--outFold ${TMPDIR}/tmp_CMC/matchUKBB_filt0.1_riskScores_ \
	--type_data tscore_corrPCs \
	--type_input zscaled \
	--risk_score T \
	--rescale_pheno T

cp ${TMPDIR}/tmp_CMC/matchUKBB_filt0.1_riskScores_*GLM* ${fold_out}
rm -r ${TMPDIR}/tmp_CMC/

