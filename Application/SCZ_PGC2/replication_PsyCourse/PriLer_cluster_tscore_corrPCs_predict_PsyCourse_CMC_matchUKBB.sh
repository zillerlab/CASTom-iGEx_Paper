#!/bin/bash
#SBATCH -o /home/luciat/SCZ_PsyCourse/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_PsyCourse_%x_matchUKBB.out
#SBATCH -e /home/luciat/SCZ_PsyCourse/err_out_fold/cluster_tscore_corrPCs_zscaled_CMC_predict_PsyCourse_%x_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=56G
#SBATCH -t 40:00:00


module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/
s_sh=/scratch-shared/luciat/

cd ${HOME}

cp SCZ_PsyCourse/OUTPUT/predictedTscores.txt ${TMPDIR}
cp eQTL_PROJECT/OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData ${TMPDIR}
input_file=${TMPDIR}/predictedTscores.txt
cov_file=SCZ_PsyCourse/INPUT_DATA/Covariates/PsyCourse_covariates.txt

${git_fold}cluster_PGmethod_corrPCs_predict_run.R \
	--inputFile ${input_file} \
	--name_cohort PsyCourse \
	--type_cluster Cases \
	--sampleAnnNew_file ${cov_file} \
	--clustFile ${TMPDIR}/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--type_data tscore \
	--type_input zscaled \
	--outFold ${TMPDIR}/matchUKBB_ \
	--functR ${git_fold}clustering_functions.R

cp ${TMPDIR}/matchUKBB_*predict* SCZ_PsyCourse/OUTPUT/update_corrPCs/



