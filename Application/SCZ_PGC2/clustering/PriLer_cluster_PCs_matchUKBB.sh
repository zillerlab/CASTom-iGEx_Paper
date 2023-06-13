#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_PCs_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_PCs_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=90G
#SBATCH -t 24:00:00
#SBATCH -p fat


module load 2019
module load R/3.5.1-intel-2019b

cd /home/luciat/eQTL_PROJECT/

git_fold=/home/luciat/castom-igex/Software/model_clustering/

mkdir -p ${TMPDIR}/tmp_PCs/

./${git_fold}cluster_PGmethod_PCs_run.R \
	--PCs_input_file INPUT_DATA/Covariates/PCs_cluster/C1-20_PGC_clustering.RData \
	--type_cluster Cases \
	--sampleAnnFile INPUT_DATA/Covariates/PCs_cluster/samples_PCs_clustering.txt \
	--outFold ${TMPDIR}/tmp_PCs/matchUKBB_ \
	--functR ${git_fold}clustering_functions.R \
	--sampleOutFile OUTPUT_all/matchUKBB_samples_to_remove_outliersUMAP_tscore_corrPCs_zscaled_clusterCases.txt

cp ${TMPDIR}/tmp_PCs/matchUKBB_*cluster* INPUT_DATA/Covariates/PCs_cluster/

rm -r ${TMPDIR}/tmp_PCs/

