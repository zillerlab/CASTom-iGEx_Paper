#!/bin/bash
#SBATCH -o /home/luciat/SCZ_PsyCourse/err_out_fold/cluster_predictEval_tscore_corrPCs_PsyCourse_CMC_%x_matchUKBB.out
#SBATCH -e /home/luciat/SCZ_PsyCourse/err_out_fold/cluster_predictEval_tscore_corrPCs_PsyCourse_CMC_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=28G
#SBATCH -t 5:00:00
#SBATCH -p thin

module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/
s_sh=/scratch-shared/luciat/

cd ${HOME}

name_cohort=PsyCourse
t=DLPC_CMC
clus_pred=SCZ_PsyCourse/OUTPUT/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData
feat_rel=SCZ_PsyCourse/OUTPUT/update_corrPCs/matchUKBB_tscoreOriginal_corrPCs_tscoreClusterCases_featAssociation.RData

fold_mod=eQTL_PROJECT/OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/
feat_rel_model=${fold_mod}matchUKBB_tscoreOriginal_corrPCs_tscoreClusterCases_featAssociation.RData
gene_loci=${fold_mod}matchUKBB_tscore_corrPCs_zscaled_clusterCases_summary_geneLoci_allTissues.txt

${git_fold}cluster_predict_evaluate_run.R \
	--cohort_name ${name_cohort[@]} \
	--functR ${git_fold}clustering_functions.R \
	--clustFile ${fold_mod}matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--clustFile_new ${clus_pred[@]} \
	--type_data tscore_corrPCs \
	--type_cluster Cases \
	--type_input zscaled \
	--outFold SCZ_PsyCourse/OUTPUT/update_corrPCs/matchUKBB_ \
	--model_name PGC2 \
	--featRel_predict ${feat_rel[@]} \
	--featRel_model ${feat_rel_model} \
	--geneLoci_summ ${gene_loci} 

