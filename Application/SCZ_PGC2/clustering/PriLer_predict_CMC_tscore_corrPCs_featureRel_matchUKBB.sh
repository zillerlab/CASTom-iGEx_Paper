#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_featRel_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_featRel_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=28G
#SBATCH --tasks-per-node 16
#SBATCH -t 24:00:00
#SBATCH -p thin

module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/
s_sh=/scratch-shared/luciat/

cd ${HOME}/eQTL_PROJECT/

c=scz_boco_eur
cp OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData ${TMPDIR}/

readarray -t tissues_gtex < OUTPUT_GTEx/Tissue_PGCgwas_red

inputFile=(${s_sh}/OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt)
tissues_tot=(DLPC_CMC)
gene_info=(OUTPUT_CMC/train_CMC/200kb/resPrior_regEval_allchr.txt)
pval_file=(OUTPUT_all/Meta_Analysis_SCZ/DLPC_CMC/pval_Dx_pheno_covCorr.RData)

for t in ${tissues_gtex[@]}
do
	echo ${t}
	inputFile+=(${s_sh}/OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt)
	pval_file+=(OUTPUT_all/Meta_Analysis_SCZ/${t}/pval_Dx_pheno_covCorr.RData)
	tissues_tot+=(${t})
	gene_info+=(OUTPUT_GTEx/train_GTEx/${t}/200kb/PGC_GWAS_bin1e-2/resPrior_regEval_allchr.txt)
done


${git_fold}cluster_associateFeat_corrPCs_run.R \
	--inputFile ${inputFile[@]} \
	--sampleAnnFile INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt \
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
	--ncores 10 \
	--tissues ${tissues_tot[@]}

cp ${TMPDIR}/matchUKBB_*Original* OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/update_corrPCs/
cp ${TMPDIR}/matchUKBB_*summary* OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/update_corrPCs/
