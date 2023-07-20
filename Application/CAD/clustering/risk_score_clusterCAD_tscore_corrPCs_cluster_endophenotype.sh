#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_rsTscore_pheno_CAD_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_rsTscore_pheno_CAD_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G


R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/
fold_cl=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
fold_input=INPUT_DATA_GTEx/CAD/Covariates/UKBB/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

# phenotypes to correct also with medication
${git_fold}cluster_associatePhenoGLM_run.R \
	--sampleAnnFile ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoDatFile ${fold_cl}tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt \
	--phenoDescFile ${cov_fold}phenotypeDescription_withMedication.txt \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold_cl}withMedication_riskScores_cp_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input corrPCs_zscaled \
	--type_sim HK \
	--clusterFile ${fold_cl}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--risk_score T \
	--rescale_pheno T 

# phenotypes to not correct also with medication
${git_fold}cluster_associatePhenoGLM_run.R \
	--sampleAnnFile ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc.txt \
	--phenoDatFile ${fold_cl}tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt \
	--phenoDescFile ${cov_fold}phenotypeDescription_withoutMedication.txt \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold_cl}withoutMedication_riskScores_cp_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input corrPCs_zscaled \
	--type_sim HK \
	--clusterFile ${fold_cl}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
    --risk_score T \
	--rescale_pheno T 
