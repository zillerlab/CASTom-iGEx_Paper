#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_%x_featRelPath_CMCset_filt.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_%x_featRelPath_CMCset_filt.err
#SBATCH -N 1
#SBATCH --mem=20G
#SBATCH --tasks-per-node 1
#SBATCH -t 24:00:00

module load 2020
module load R/4.0.2-intel-2020a

cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_clustering/

readarray -t name_cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names_CLUST

input_fold_t=(OUTPUT_CMC/predict_PGC/200kb/)
cov_file=()
tissues_tot=(DLPC_CMC)
pval_file=(OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/pval_Dx_pheno_covCorr_customPath_CMC_GeneSets.RData)

mkdir -p ${TMPDIR}/tmp_CMC_t
cp OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData ${TMPDIR}/tmp_CMC_t/

for c in ${name_cohorts[@]}
do
	echo ${c}
	cov_file+=(INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt)
done


# CMCset pathways-scores

${git_fold}cluster_associateFeat_corrPCs_multipleCohorts_run.R \
	--type_data_cluster tscore \
	--tissues ${tissues_tot[@]} \
	--inputFold ${input_fold_t[@]} \
	--additional_name_file /devgeno0.01_testdevgeno0/Pathway_CMC_GeneSets_scores.txt \
	--name_cohorts ${name_cohorts[@]} \
	--type_cluster Cases \
	--pvalresFile ${pval_file[@]} \
	--sampleAnnFile ${cov_file[@]} \
	--pval_id 1 \
	--type_data customPath_CMC_GeneSets \
	--type_input zscaled \
	--outFold ${TMPDIR}/tmp_CMC_t/matchUKBB_filt0.1_ \
	--functR ${git_fold}clustering_functions.R \
	--clusterFile ${TMPDIR}/tmp_CMC_t/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData \
	--ncores 1

cp ${TMPDIR}/tmp_CMC_t/matchUKBB_filt0.1_customPath_CMC_GeneSetsOriginal*Cluster* OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

rm -r ${TMPDIR}/tmp_CMC_t/



