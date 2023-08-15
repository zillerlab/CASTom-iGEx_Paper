#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_PCs_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_PCs_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=28G
#SBATCH -t 24:00:00


module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/

cd ${HOME}/eQTL_PROJECT/

${git_fold}cluster_PGmethod_PCs_run.R \
	--PCs_input_file INPUT_DATA/Covariates/PCs_cluster/C1-20_PGC_clustering.RData \
	--type_cluster Cases \
	--sampleAnnFile INPUT_DATA/Covariates/PCs_cluster/samples_PCs_clustering.txt \
	--outFold ${TMPDIR}/matchUKBB_ \
	--functR ${git_fold}clustering_functions.R \
	--sampleOutFile OUTPUT_all/clustering_res_matchUKBB_corrPCs/matchUKBB_samples_to_remove_outliersUMAP_tscore_corrPCs_zscaled_clusterCases.txt

cp ${TMPDIR}/matchUKBB_*cluster* INPUT_DATA/Covariates/PCs_cluster/

