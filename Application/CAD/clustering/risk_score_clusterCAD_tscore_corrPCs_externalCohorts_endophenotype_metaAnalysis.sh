#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_rsTscore_metaAnalysis_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_rsTscore_metaAnalysis_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G


R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
name_c=(German1 German2 German3 German4 German5 CG WTCCC LURIC MG)

pheno_file=()
sample_file=()
clust_file=()
for i in ${name_c[@]}
do
	pheno_file+=(OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${i}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt)
	sample_file+=(INPUT_DATA_GTEx/CAD/Covariates/${i}/covariateMatrix.txt)
	clust_file+=(OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${i}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData)
done

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/

mkdir -p OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/Meta_Analysis_CAD/CAD_HARD_clustering/update_corrPCs/
fold_out=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/Meta_Analysis_CAD/CAD_HARD_clustering/update_corrPCs/


${git_fold}cluster_associatePhenoGLM_multipleCohorts_metaAnalysis_run.R \
	--name_cohorts ${name_c[@]} \
	--phenoDatFile ${pheno_file[@]} \
	--phenoDescFile INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/phenotypeDescription.txt \
	--sampleAnnFile ${sample_file[@]} \
	--clusterFile ${clust_file[@]} \
	--type_cluster Cases \
	--functR ${git_fold}clustering_functions.R \
	--outFold ${fold_out}riskScores_cp_ \
	--type_data tscore \
	--type_input corrPCs_zscaled \
	--risk_score T













