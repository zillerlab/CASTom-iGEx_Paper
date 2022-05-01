#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_featRel_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_featRel_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=40G
#SBATCH --tasks-per-node 10
#SBATCH -t 48:00:00

module load 2019
module load R/3.5.1-intel-2019b

cd /home/luciat/eQTL_PROJECT/

c=scz_boco_eur
git_fold=/home/luciat/castom-igex/Software/model_clustering/

mkdir -p ${TMPDIR}/tmp_CMC/

cp OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_filt0.1_tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData ${TMPDIR}/tmp_CMC/

readarray -t tissues_gtex < OUTPUT_GTEx/Tissue_PGCgwas_red

inputFile=(OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt)
tissues_tot=(DLPC_CMC)
gene_info=(OUTPUT_CMC/train_CMC/200kb/resPrior_regEval_allchr.txt)
pval_file=(OUTPUT_all/Meta_Analysis_SCZ/DLPC_CMC/pval_Dx_pheno_covCorr.RData)

for t in ${tissues_gtex[@]}
do
	echo ${t}
	inputFile+=(OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt)
	pval_file+=(OUTPUT_all/Meta_Analysis_SCZ/${t}/pval_Dx_pheno_covCorr.RData)
	tissues_tot+=(${t})
	gene_info+=(OUTPUT_GTEx/train_GTEx/${t}/200kb/PGC_GWAS_bin1e-2/resPrior_regEval_allchr.txt)
done


Rscript ${git_fold}cluster_associateFeat_corrPCs_run.R \
	--inputFile ${inputFile[@]} \
	--sampleAnnFile INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt \
	--split_tot 0 \
	--pvalresFile ${pval_file[@]} \
	--geneInfoFile ${gene_info[@]} \
	--pval_id 1 \
	--min_genes_path 2 \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${TMPDIR}/tmp_CMC/matchUKBB_filt0.1_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input zscaled \
	--clusterFile ${TMPDIR}/tmp_CMC/matchUKBB_filt0.1_tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData \
	--type_data_cluster tscore \
	--ncores 10 \
	--tissues ${tissues_tot[@]}

cp ${TMPDIR}/tmp_CMC/matchUKBB_filt0.1_*Original* OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/update_corrPCs/

rm -r ${TMPDIR}/tmp_CMC/

