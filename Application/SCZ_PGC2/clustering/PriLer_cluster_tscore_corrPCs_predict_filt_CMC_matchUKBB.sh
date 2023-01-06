#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=90G
#SBATCH -t 120:00:00


module load 2019
module load R/3.5.1-intel-2019b

cd /home/luciat/eQTL_PROJECT/

c=scz_boco_eur
git_fold=/home/luciat/castom-igex/Software/model_clustering/

mkdir -p ${TMPDIR}/tmp_CMC_t_f

cp OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt ${TMPDIR}/tmp_CMC_t_f/
cp OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData ${TMPDIR}/tmp_CMC_t_f/
input_file=${TMPDIR}/tmp_CMC_t_f/predictedTscores.txt
cov_file=INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt

thr=$1
Rscript ${git_fold}cluster_PGmethod_corrPCs_predict_run.R \
	--inputFile ${input_file} \
	--name_cohort ${c} \
	--type_cluster Cases \
	--sampleAnnNew_file ${cov_file} \
	--clustFile ${TMPDIR}/tmp_CMC_t_f/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--type_data tscore \
	--type_input zscaled \
	--tissues_name DLPC_CMC \
	--outFold ${TMPDIR}/tmp_CMC_t_f/matchUKBB_filt0.1_ \
	--functR ${git_fold}clustering_functions.R

cp ${TMPDIR}/tmp_CMC_t_f/matchUKBB_filt0.1_*predict* OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/update_corrPCs/

rm -r ${TMPDIR}/tmp_CMC_t_f/


