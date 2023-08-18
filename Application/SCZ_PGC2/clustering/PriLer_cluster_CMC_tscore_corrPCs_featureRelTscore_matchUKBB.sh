#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_%x_featRelTscore.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_%x_featRelTscore.err
#SBATCH -N 1
#SBATCH --mem=112G
#SBATCH --tasks-per-node 16
#SBATCH -t 30:00:00

module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/
s_sh=/scratch-shared/luciat/

cd ${HOME}/eQTL_PROJECT/

readarray -t name_cohorts < INPUT_DATA/SCZ_cohort_names_CLUST
readarray -t tissues_gtex < OUTPUT_GTEx/Tissue_PGCgwas_red

input_fold_t=(${s_sh}OUTPUT_CMC/predict_PGC/200kb/)
cov_file=()
tissues_tot=(DLPC_CMC)
gene_info=(OUTPUT_CMC/train_CMC/200kb/resPrior_regEval_allchr.txt)
pval_file=(OUTPUT_all/Meta_Analysis_SCZ/DLPC_CMC/pval_Dx_pheno_covCorr.RData)

cp OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData ${TMPDIR}

for t in ${tissues_gtex[@]}
do
	echo ${t}
	input_fold_t+=(${s_sh}OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/)
	pval_file+=(OUTPUT_all/Meta_Analysis_SCZ/${t}/pval_Dx_pheno_covCorr.RData)
	tissues_tot+=(${t})
	gene_info+=(OUTPUT_GTEx/train_GTEx/${t}/200kb/PGC_GWAS_bin1e-2/resPrior_regEval_allchr.txt)
done

for c in ${name_cohorts[@]}
do
	echo ${c}
	cov_file+=(INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt)
done


# tscore
${git_fold}cluster_associateFeat_corrPCs_multipleCohorts_run.R \
	--type_data_cluster tscore \
	--tissues ${tissues_tot[@]} \
	--inputFold ${input_fold_t[@]} \
	--additional_name_file /devgeno0.01_testdevgeno0/predictedTscores.txt \
	--name_cohorts ${name_cohorts[@]} \
	--type_cluster Cases \
	--pvalresFile ${pval_file[@]} \
	--sampleAnnFile ${cov_file[@]} \
	--pval_id 1 \
	--type_data tscore \
	--type_input zscaled  \
	--outFold ${TMPDIR}/matchUKBB_ \
	--functR ${git_fold}clustering_functions.R \
	--clusterFile ${TMPDIR}/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--ncores 10 \
	--geneInfoFile ${gene_info[@]} \
	--pvalcorr_thr 0.01 

cp ${TMPDIR}/matchUKBB_tscoreOriginal*Cluster* OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

cp ${TMPDIR}/matchUKBB_*summary* OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/




