#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/compare_riskScore_clusterGerman_CAD_UKBBrel_endoAnalys_tscore_corrPCs_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/compare_riskScore_clusterGerman_CAD_UKBBrel_endoAnalys_tscore_corrPCs_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G

R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/Meta_Analysis_CAD/CAD_HARD_clustering/update_corrPCs/
fold_UKBB=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/

${git_fold}compare_endophenotypeAnalysis_clusterRiskScore_run.R \
	--riskScore_analysis_file ${fold}/riskScores_cp_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM_metaAnalysis.RData \
	--endopheno_analysis_file ${fold_UKBB}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM_combined.txt \
	--pheno_name CAD_HARD \
	--outFold ${fold}cp_metaAnalysis_ \
	--color_pheno_file ${ref_fold}color_pheno_type_UKBB.txt \
	--thr_plot 1e-50 \
	--meta_analysis T \
	--R2_pheno_rs_file ${fold_UKBB}tscore_corr2Thr0.1_relatedPhenotypes_R2_risk_score_phenotype.txt \
	--pval_pheno_show 0.005


