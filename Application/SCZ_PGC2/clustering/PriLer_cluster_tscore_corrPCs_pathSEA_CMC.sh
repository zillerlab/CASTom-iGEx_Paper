#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/cluster_tscore_SCZ_corrPCs_pathSEA_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/cluster_tscore_SCZ_corrPCs_pathSEA_%x.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem=20G

R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/

fold_cl=clustering_res_matchUKBB_corrPCs/DLPC_CMC/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

${git_fold}pathSEA_path_group_run.R \
	--pathCluster_file ${fold_cl}reduced_matchUKBB_pathOriginal_filtJS0.2_corrPCs_tscoreClusterCases_featAssociation.RData \
	--outFold ${fold_cl} \
	--atc_file /psycl/g/mpsziller/lucia/drug_targeting/WHO\ ATC-DDD\ 2021-12-03.csv \
	--cmap_fold /psycl/g/mpsziller/lucia/refData/Cmap_MSigDB_v6.1_PEPs \
	--type_cluster Cases

