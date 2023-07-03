#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_CAD_bootstrap50_t%a_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_CAD_bootstrap50_t%a_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=15G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
rep=$1

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

${git_fold}cluster_PGmethod_corrPCs_run.R \
	--inputFile ${fold}predictedTscores_splitGenes \
	--sampleAnnFile ${cov_fold}bootstrap50/covariateMatrix_CADHARD_Cases_rep${rep}.txt \
	--split_tot 100 \
	--pvalresFile ${fold}pval_CAD_pheno_covCorr.RData \
	--pval_id 1 \
	--min_genes_path 2 \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold}CAD_HARD_clustering/update_corrPCs/variable_kNNpar/bootstrap50_rep${rep}_kNN20_ \
	--functR ${git_fold}clustering_functions.R \
	--corr_thr 0.9 \
	--type_input zscaled \
	--kNN_par 20 \
	--tissues_name ${t}
