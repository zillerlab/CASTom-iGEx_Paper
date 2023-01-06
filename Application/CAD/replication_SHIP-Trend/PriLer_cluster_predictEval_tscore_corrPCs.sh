#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predictEval_tscore_corrPCs_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predictEval_tscore_corrPCs_t%a.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem=50G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_SHIP/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < Tissues
t=$(eval echo "\${tissues[${id_t}-1]}")

cohort_name=SHIP-TREND
fold_mod=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
fold_cl=Results/PriLer/${t}/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

Rscript ${git_fold}cluster_predict_evaluate_run.R \
	--cohort_name ${cohort_name} \
	--functR ${git_fold}clustering_functions.R \
	--clustFile ${fold_mod}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--clustFile_new ${fold_cl}tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData \
	--type_data tscore_corrPCs \
	--type_cluster Cases \
	--type_input zscaled \
	--outFold ${fold_cl} \
	--model_name UKBB \
	--featRel_predict ${fold_cl}tscoreOriginal_corrPCs_tscoreClusterCases_featAssociation.RData \
	--featRel_model ${fold_mod}tscoreOriginal_corrPCs_tscoreClusterCases_featAssociation.RData \
	--geneLoci_summ ${fold_mod}tscore_corrPCs_zscaled_clusterCases_summary_geneLoci_allTissues.txt




