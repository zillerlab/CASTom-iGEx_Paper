#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/compare_riskScore_cluster_CAD_UKBBrel_endoAnalys_tscore_corrPCs_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/compare_riskScore_cluster_CAD_UKBBrel_endoAnalys_tscore_corrPCs_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold_cl=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/

${git_fold}compare_endophenotypeAnalysis_clusterRiskScore_run.R \
	--riskScore_analysis_file ${fold_cl}/withMedication_riskScores_cp_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData ${fold_cl}/withoutMedication_riskScores_cp_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData \
	--endopheno_analysis_file ${fold_cl}/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM_combined.txt \
	--pheno_name CAD_HARD \
	--outFold ${fold_cl}cp_ \
	--color_pheno_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/color_pheno_type_UKBB.txt \
	--thr_plot 1e-100 \
	--R2_pheno_rs_file ${fold_cl}tscore_corr2Thr0.1_relatedPhenotypes_R2_risk_score_phenotype.txt \
	--pval_pheno_show 0.005

