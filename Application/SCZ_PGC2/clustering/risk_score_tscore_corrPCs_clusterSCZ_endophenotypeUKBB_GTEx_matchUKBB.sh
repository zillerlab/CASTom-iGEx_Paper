#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_cluster_tscore_corrPCs_zscaled_GLManalysis_%x_t%a_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/riskScore_UKBB_cluster_tscore_corrPCs_zscaled_GLManalysis_%x_t%a_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=28G
#SBATCH -t 24:00:00
#SBATCH -p thin


module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/
s_sh=/scratch-shared/luciat/

cd ${HOME}/eQTL_PROJECT/
readarray -t tissues < OUTPUT_GTEx/Tissue_PGCgwas_red
id=${SLURM_ARRAY_TASK_ID}
t=$(eval echo "\${tissues[${id}-1]}")

fold_UKBB=${HOME}/UKBB_SCZrelated/

mkdir -p ${TMPDIR}/
fold_out=OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

cp ${fold_UKBB}/phenotypeDescription_rsSCZ.txt ${TMPDIR}/
cp ${fold_out}matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData ${TMPDIR}/
cp ${fold_out}matchUKBB_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz ${TMPDIR}/

clust_file=${TMPDIR}/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData

${git_fold}cluster_associatePhenoGLM_run.R \
	--phenoDatFile ${TMPDIR}/matchUKBB_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt.gz \
	--phenoDescFile ${TMPDIR}/phenotypeDescription_rsSCZ.txt \
	--sampleAnnFile INPUT_DATA/Covariates/PCs_cluster/samples_PCs_clustering.txt \
	--clusterFile ${clust_file} \
	--type_cluster Cases \
	--functR ${git_fold}clustering_functions.R \
	--outFold ${TMPDIR}/matchUKBB_riskScores_ \
	--type_data tscore_corrPCs \
	--type_input zscaled \
	--risk_score T \
	--rescale_pheno T

cp ${TMPDIR}/matchUKBB_riskScores_*GLM* ${fold_out}

