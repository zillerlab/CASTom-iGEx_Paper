#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_cluster_PCs_GLManalysis_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_cluster_PCs_GLManalysis_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=28G
#SBATCH -t 24:00:00
#SBATCH -p thin


module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/
s_sh=/scratch-shared/luciat/

cd ${HOME}/eQTL_PROJECT/
fold_UKBB=${HOME}/UKBB_SCZrelated/

fold_out=OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/
fold_cl=INPUT_DATA/Covariates/PCs_cluster/

cp ${fold_UKBB}/phenotypeDescription_rsSCZ_updated.txt ${TMPDIR}
cp ${fold_cl}/matchUKBB_PCs_clusterCases_PGmethod_HKmetric.RData ${TMPDIR}
cp ${fold_out}/matchUKBB_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz ${TMPDIR}

clust_file=${TMPDIR}/matchUKBB_PCs_clusterCases_PGmethod_HKmetric.RData

${git_fold}cluster_associatePhenoGLM_run.R \
	--phenoDatFile ${TMPDIR}/matchUKBB_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz \
	--phenoDescFile ${TMPDIR}/phenotypeDescription_rsSCZ_updated.txt \
	--sampleAnnFile INPUT_DATA/Covariates/PCs_cluster/samples_PCs_clustering.txt \
	--clusterFile ${clust_file} \
	--type_cluster Cases \
	--functR ${git_fold}clustering_functions.R \
	--outFold ${TMPDIR}/matchUKBB_riskScores_ \
	--type_data PCs \
	--type_input original \
	--risk_score T \
	--rescale_pheno T

cp ${TMPDIR}/matchUKBB_riskScores_*GLM* ${fold_cl}
