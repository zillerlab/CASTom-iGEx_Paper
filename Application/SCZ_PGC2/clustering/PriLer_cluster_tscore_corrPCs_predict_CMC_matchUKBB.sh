#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_%x_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=84G
#SBATCH -t 48:00:00
#SBATCH -p thin

module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/

cd ${HOME}/eQTL_PROJECT
c=scz_boco_eur
s_sh=/scratch-shared/luciat/

cp OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData ${TMPDIR}
input_file=${s_sh}/OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt
cov_file=INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt

${git_fold}cluster_PGmethod_corrPCs_predict_run.R \
	--inputFile ${input_file} \
	--name_cohort ${c} \
	--type_cluster Cases \
	--sampleAnnNew_file ${cov_file} \
	--clustFile ${TMPDIR}/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--type_data tscore \
	--type_input zscaled \
	--outFold ${TMPDIR}/matchUKBB_ \
	--functR ${git_fold}clustering_functions.R

cp ${TMPDIR}/matchUKBB_*predict* OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/update_corrPCs/


