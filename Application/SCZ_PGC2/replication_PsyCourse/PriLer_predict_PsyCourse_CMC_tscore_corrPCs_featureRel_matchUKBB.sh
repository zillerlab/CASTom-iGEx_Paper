#!/bin/bash
#SBATCH -o /home/luciat/SCZ_PsyCourse/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_PsyCourse_featRel_%x_matchUKBB.out
#SBATCH -e /home/luciat/SCZ_PsyCourse/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_PsyCourse_featRel_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=28G
#SBATCH -t 24:00:00
#SBATCH -p thin


module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/
s_sh=/scratch-shared/luciat/

cd ${HOME}
cp SCZ_PsyCourse/OUTPUT/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData ${TMPDIR}

inputFile=(SCZ_PsyCourse/OUTPUT/predictedTscores.txt)
tissues_tot=(DLPC_CMC)
gene_info=(eQTL_PROJECT/OUTPUT_CMC/train_CMC/200kb/resPrior_regEval_allchr.txt)
pval_file=(eQTL_PROJECT/OUTPUT_all/Meta_Analysis_SCZ/DLPC_CMC/pval_Dx_pheno_covCorr.RData)

${git_fold}cluster_associateFeat_corrPCs_run.R \
	--inputFile ${inputFile[@]} \
	--sampleAnnFile SCZ_PsyCourse/INPUT_DATA/Covariates/PsyCourse_covariates.txt \
	--split_tot 0 \
	--pvalresFile ${pval_file[@]} \
	--geneInfoFile ${gene_info[@]} \
	--pval_id 1 \
	--min_genes_path 2 \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${TMPDIR}/matchUKBB_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input zscaled \
	--clusterFile ${TMPDIR}/matchUKBB_tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData \
	--type_data_cluster tscore \
	--ncores 1 \
	--tissues ${tissues_tot[@]}

cp ${TMPDIR}/matchUKBB_*Original* SCZ_PsyCourse/OUTPUT/update_corrPCs/
cp ${TMPDIR}/matchUKBB_*summary* SCZ_PsyCourse/OUTPUT/update_corrPCs/


