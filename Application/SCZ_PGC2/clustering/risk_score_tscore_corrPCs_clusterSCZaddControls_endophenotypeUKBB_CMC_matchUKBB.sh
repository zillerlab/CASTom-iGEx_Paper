#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_clusterCasesaddControls_tscore_corrPCs_zscaled_GLManalysis_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_clusterCasesaddControls_tscore_corrPCs_zscaled_GLManalysis_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=28G
#SBATCH -t 24:00:00
#SBATCH -p thin


module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/
s_sh=/scratch-shared/luciat/

cd ${HOME}/eQTL_PROJECT/
readarray -t name_cohorts < INPUT_DATA/SCZ_cohort_names

fold_UKBB=${HOME}/UKBB_SCZrelated/
fold_out=OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

cp ${fold_UKBB}/phenotypeDescription_rsSCZ_updated.txt ${TMPDIR}/
cp ${fold_out}matchUKBB_tscore_corrPCs_zscaled_clusterCases_addControls_PGmethod_HKmetric_minimal.RData ${TMPDIR}/
cp ${fold_out}matchUKBB_allSamples_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz ${TMPDIR}/

clust_file=${TMPDIR}/matchUKBB_tscore_corrPCs_zscaled_clusterCases_addControls_PGmethod_HKmetric_minimal.RData

${git_fold}cluster_associatePhenoGLM_run.R \
	--phenoDatFile ${TMPDIR}/matchUKBB_allSamples_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz \
	--phenoDescFile ${TMPDIR}/phenotypeDescription_rsSCZ_updated.txt \
	--sampleAnnFile INPUT_DATA/Covariates/PCs_cluster/samples_PCs_clustering.txt \
	--clusterFile ${clust_file} \
	--type_cluster All \
	--functR ${git_fold}clustering_functions.R \
	--outFold ${TMPDIR}/matchUKBB_allSamples_riskScores_ \
	--type_data tscore_corrPCs \
	--type_input zscaled \
	--risk_score T \
	--rescale_pheno T

cp ${TMPDIR}/matchUKBB_allSamples_riskScores_*GLM* ${fold_out}


