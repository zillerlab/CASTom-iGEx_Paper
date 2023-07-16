#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_CAD_corrPCs_pathSEA_t%a_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_CAD_corrPCs_pathSEA_t%a_%x.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem=20G

R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")


fold_cl=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/

${git_fold}pathSEA_path_group_run.R \
	--pathCluster_file ${fold_cl}pathOriginal_filtJS0.2_corrPCs_tscoreClusterCases_featAssociation.RData \
	--outFold ${fold_cl} \
	--atc_file ${ref_fold}WHO\ ATC-DDD\ 2021-12-03.csv \
	--cmap_fold /psycl/g/mpsziller/lucia/refData/Cmap_MSigDB_v6.1_PEPs \
	--type_cluster Cases
	
 

