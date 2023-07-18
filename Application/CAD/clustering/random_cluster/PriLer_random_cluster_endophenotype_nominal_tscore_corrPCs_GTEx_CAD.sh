#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_nominal_pheno_CAD_t11_randomREP%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_nominal_pheno_CAD_t11_randomREP%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=5G

R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id=${SLURM_ARRAY_TASK_ID}
t=Liver

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/random_cluster/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
fold_input=INPUT_DATA_GTEx/CAD/Covariates/UKBB/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/


#### rescale continuous phenotypes
${git_fold}cluster_associatePhenoGLM_run.R \
	--sampleAnnFile ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc.txt \
	--phenoDatFile ${fold_input}phenoMatrix_CADpheno_nominal.txt \
	--phenoDescFile ${fold_input}phenotypeDescription_manualProc_CADpheno_nominal.txt \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold}rep${id}_nominalAnalysis_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input corrPCs_zscaled \
	--type_sim HK \
	--clusterFile ${fold}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_rep${id}.RData

rm ${fold}rep${id}_nominalAnalysis_*pairwise* ${fold}rep${id}_nominalAnalysis_*.RData
