#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predict_tscore_corrPCs_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predict_tscore_corrPCs_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=50G

# R version changed because it was impossible to install umap package on R/3.5.3 (cluster issue, previously working!)
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_SHIP/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < Tissues
t=$(eval echo "\${tissues[${id_t}-1]}")

fold_mod=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/

fold=Results/PriLer/${t}/
cov_fold_mod=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
cov_fold=Results/PriLer/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

Rscript ${git_fold}cluster_PGmethod_corrPCs_predict_run.R \
	--inputFile ${fold}predictedTscores.txt \
	--sampleAnnNew_file ${cov_fold}SHIP-TREND_gPC_SHIP_2022_27_withSex.txt \
	--sampleAnn_file ${cov_fold_mod}covariateMatrix_CADHARD_All.txt \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold} \
	--functR ${git_fold}clustering_functions.R \
	--type_input zscaled \
	--tissues_name ${t} \
	--clustFile ${fold_mod}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--name_cohort SHIP-TREND
