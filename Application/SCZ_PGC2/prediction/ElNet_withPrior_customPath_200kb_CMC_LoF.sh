#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/custom_pathDiff_c%a_CMC_LoF.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/custom_pathDiff_c%a_CMC_LoF.err
#SBATCH -N 1
#SBATCH --mem=20G
#SBATCH -t 48:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/

id_c=${SLURM_ARRAY_TASK_ID}
readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

git_fold=/home/luciat/castom-igex/Software/model_prediction/

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_CMC_path/
cp ${git_fold}refData/SCZ_LoF_GeneSets_ordered.RData ${TMPDIR}/tmp_${id_c}_CMC_path/
cp OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt ${TMPDIR}/tmp_${id_c}_CMC_path/

${git_fold}pathScore_customGeneList_run.R \
	--sampleAnn_file INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt \
	--pathwayStruct_file ${TMPDIR}/tmp_${id_c}_CMC_path/SCZ_LoF_GeneSets_ordered.RData \
	--tscore_file ${TMPDIR}/tmp_${id_c}_CMC_path/predictedTscores.txt \
	--outFold ${TMPDIR}/tmp_${id_c}_CMC_path/ \
	--geneSetName SCZ_LoF_GeneSets

cp ${TMPDIR}/tmp_${id_c}_CMC_path/Pathway* OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/

rm -r ${TMPDIR}/tmp_${id_c}_CMC_path/