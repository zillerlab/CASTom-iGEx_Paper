#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_PCs_CAD_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_PCs_CAD_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/

${git_fold}cluster_PGmethod_PCs_run.R \
	--PCs_input_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/PCs1-40_UKBB.RData \
	--sampleAnnFile ${fold}covariateMatrix_CADHARD_All.txt \
	--type_cluster $1 \
	--outFold ${fold} \
	--functR ${git_fold}clustering_functions.R \
	--kNN_par 30

