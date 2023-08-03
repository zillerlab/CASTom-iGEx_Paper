#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_%x_featRelPath.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_%x_featRelPath.err
#SBATCH -N 1
#SBATCH --mem=100G
#SBATCH --tasks-per-node 10
#SBATCH -t 24:00:00
#SBATCH -p fat

module load 2019
module load R/3.5.1-intel-2019b

cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_clustering/

readarray -t name_cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names_CLUST
readarray -t tissues_gtex < OUTPUT_GTEx/Tissue_PGCgwas_red

input_fold_t=(OUTPUT_CMC/predict_PGC/200kb/)
cov_file=()
tissues_tot=(DLPC_CMC)
pval_file=(OUTPUT_all/Meta_Analysis_SCZ/DLPC_CMC/pval_Dx_pheno_covCorr.RData)
path_ann=(OUTPUT_all/Meta_Analysis_SCZ/DLPC_CMC/selected_pathways_JSthr0.2.txt)

mkdir -p ${TMPDIR}/tmp_CMC_t
cp OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData ${TMPDIR}/tmp_CMC_t/

for t in ${tissues_gtex[@]}
do
	echo ${t}
	input_fold_t+=(OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/)
	pval_file+=(OUTPUT_all/Meta_Analysis_SCZ/${t}/pval_Dx_pheno_covCorr.RData)
	path_ann+=(OUTPUT_all/Meta_Analysis_SCZ/${t}/selected_pathways_JSthr0.2.txt)
	tissues_tot+=(${t})
done

for c in ${name_cohorts[@]}
do
	echo ${c}
	cov_file+=(INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt)
done


# tscore
${git_fold}cluster_associatePath_corrPCs_multipleCohorts_run.R \
        --name_cohorts ${name_cohorts[@]} \
	--type_data_cluster tscore \
	--tissues ${tissues_tot[@]} \
	--inputFold ${input_fold_t[@]} \
	--additional_name_file /devgeno0.01_testdevgeno0/ \
	--name_cohorts ${name_cohorts[@]} \
	--type_cluster Cases \
	--pvalresFile ${pval_file[@]} \
	--sampleAnnFile ${cov_file[@]} \
	--pval_id 1 \
	--type_data path \
	--type_input zscaled  \
	--outFold ${TMPDIR}/tmp_CMC_t/matchUKBB_filt0.1_ \
	--functR ${git_fold}clustering_functions.R \
	--clusterFile ${TMPDIR}/tmp_CMC_t/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData \
	--ncores 10 \
	--thr_js 0.2 \
	--path_filt_file ${path_ann[@]}

cp ${TMPDIR}/tmp_CMC_t/matchUKBB_filt0.1_pathOriginal*Cluster* OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/

rm -r ${TMPDIR}/tmp_CMC_t/



