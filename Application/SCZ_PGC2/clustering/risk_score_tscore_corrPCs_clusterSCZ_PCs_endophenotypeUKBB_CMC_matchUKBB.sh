#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_cluster_PCs_GLManalysis_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_cluster_PCs_GLManalysis_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=30G
#SBATCH -t 24:00:00
#SBATCH -p fat


module load 2019
module load R/3.5.1-intel-2019b


cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_clustering/

fold_UKBB=/home/luciat/UKBB_SCZrelated/

mkdir -p ${TMPDIR}/tmp_PCs/
fold_out=OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/
fold_cl=INPUT_DATA/Covariates/PCs_cluster/

cp ${fold_UKBB}/phenotypeDescription_rsSCZ_updated.txt ${TMPDIR}/tmp_PCs/
cp ${fold_cl}matchUKBB_PCs_clusterCases_PGmethod_HKmetric.RData ${TMPDIR}/tmp_PCs/
cp ${fold_out}matchUKBB_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz ${TMPDIR}/tmp_PCs/

clust_file=${TMPDIR}/tmp_PCs/matchUKBB_PCs_clusterCases_PGmethod_HKmetric.RData

${git_fold}cluster_associatePhenoGLM_run.R \
	--phenoDatFile ${TMPDIR}/tmp_PCs/matchUKBB_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz \
	--phenoDescFile ${TMPDIR}/tmp_PCs/phenotypeDescription_rsSCZ_updated.txt \
	--sampleAnnFile INPUT_DATA/Covariates/PCs_cluster/samples_PCs_clustering.txt \
	--clusterFile ${clust_file} \
	--type_cluster Cases \
	--functR ${git_fold}clustering_functions.R \
	--outFold ${TMPDIR}/tmp_PCs/matchUKBB_riskScores_ \
	--type_data PCs \
	--type_input original \
	--risk_score T \
	--rescale_pheno T

cp ${TMPDIR}/tmp_PCs/matchUKBB_riskScores_*GLM* ${fold_out}
rm -r ${TMPDIR}/tmp_PCs/

