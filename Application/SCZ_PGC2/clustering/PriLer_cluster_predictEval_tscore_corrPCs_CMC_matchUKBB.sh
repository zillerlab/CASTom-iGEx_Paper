#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_predictEval_tscore_corrPCs_CMC_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_predictEval_tscore_corrPCs_CMC_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=28G
#SBATCH -t 5:00:00
#SBATCH -p thin

module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/
s_sh=/scratch-shared/luciat/

name_cohort=scz_boco_eur
t=DLPC_CMC

cd ${HOME}/eQTL_PROJECT/

fold_mod=OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/
clus_pred=()
pheno_pred=()
feat_rel=()
pheno_pred=()
for i in ${name_cohort[@]}
do
	clus_pred+=(OUTPUT_CMC/predict_PGC/200kb/${i}/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData)
        pheno_pred+=(INPUT_DATA/Covariates/${i}.phenoMatrix_extra.txt)
	feat_rel+=(OUTPUT_CMC/predict_PGC/200kb/${i}/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscoreOriginal_corrPCs_tscoreClusterCases_featAssociation.RData)
done

cp ${fold_mod}matchUKBB_tscoreOriginal_corrPCs_tscoreClusterCases_featAssociation.RData ${TMPDIR}
cp ${fold_mod}matchUKBB_tscore_corrPCs_zscaled_clusterCases_summary_geneLoci_allTissues.txt ${TMPDIR}
cp ${fold_mod}matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData ${TMPDIR}
feat_rel_model=${TMPDIR}/matchUKBB_tscoreOriginal_corrPCs_tscoreClusterCases_featAssociation.RData
gene_loci=${TMPDIR}/matchUKBB_tscore_corrPCs_zscaled_clusterCases_summary_geneLoci_allTissues.txt

${git_fold}cluster_predict_evaluate_run.R \
	--cohort_name ${name_cohort[@]} \
	--functR ${git_fold}clustering_functions.R \
	--clustFile ${TMPDIR}/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--clustFile_new ${clus_pred[@]} \
	--type_data tscore_corrPCs \
	--type_cluster Cases \
	--type_input zscaled \
	--phenoNew_file ${pheno_pred[@]} \
	--outFold OUTPUT_CMC/predict_PGC/200kb/${name_cohort}/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_ \
	--model_name PGC2 \
	--featRel_predict ${feat_rel[@]} \
	--featRel_model ${feat_rel_model} \
	--geneLoci_summ ${gene_loci} \



