#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predict_pathRpheno_diff_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predict_pathRpheno_diff_t%a.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem=30G

R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_SHIP/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < Tissues
t=$(eval echo "\${tissues[${id_t}-1]}")

cohort_name=SHIP-TREND
fold_cl=Results/PriLer/${t}/
fold_input=GENE_EXPR/
fold_sample=Results/PriLer/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

Rscript ${git_fold}cluster_predict_associatePhenoGLM_run.R \
	--cohort_name ${cohort_name} \
	--functR ${git_fold}clustering_functions.R \
	--clustFile_new ${fold_cl}tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData \
	--type_data tscore_corrPCs \
	--type_cluster Cases \
	--type_input zscaled \
	--outFold ${fold_cl}Reactome_ \
	--model_name UKBB \
	--phenoNew_file ${fold_input}Pathway_Reactome_scores_phenotypeFormat.txt \
	--covNew_file ${fold_sample}SHIP-TREND_gPC_SHIP_2022_27_withSex.txt
