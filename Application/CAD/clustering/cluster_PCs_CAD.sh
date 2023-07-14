#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_PCs_CAD_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_PCs_CAD_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/

${git_fold}cluster_PGmethod_PCs_run.R \
	--PCs_input_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/PCs1-40_UKBB.RData \
	--sampleAnnFile ${fold}covariateMatrix_CADHARD_All.txt \
	--type_cluster $1 \
	--outFold ${fold} \
	--functR ${git_fold}clustering_functions.R \
	--kNN_par 20

