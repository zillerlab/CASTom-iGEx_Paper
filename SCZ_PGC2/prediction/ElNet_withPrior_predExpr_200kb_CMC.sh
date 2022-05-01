#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/predExpr_c%a_CMC.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/predExpr_c%a_CMC.err
#SBATCH -N 1
#SBATCH --mem=40G
#SBATCH -t 48:00:00


module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/

id_c=${SLURM_ARRAY_TASK_ID}
readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

git_fold=/home/luciat/castom-igex/Software/model_prediction/

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_CMC
cp /home/luciat/eQTL_PROJECT/INPUT_DATA_CMC/SCZ-PGC/Genotype_data/${c}/Genotype* ${TMPDIR}/tmp_${id_c}_CMC/
cp OUTPUT_CMC/train_CMC/200kb/res* ${TMPDIR}/tmp_${id_c}_CMC/
cp OUTPUT_CMC/train_CMC/*mtx ${TMPDIR}/tmp_${id_c}_CMC/

${git_fold}Priler_predictGeneExp_run.R \
	--genoDat_file ${TMPDIR}/tmp_${id_c}_CMC/Genotype_dosage_ \
	--covDat_file INPUT_DATA/Covariates/${c}.covariateMatrix.txt \
	--outFold ${TMPDIR}/tmp_${id_c}_CMC/ \
	--outTrain_fold ${TMPDIR}/tmp_${id_c}_CMC/ \
	--InfoFold ${TMPDIR}/tmp_${id_c}_CMC/

cp ${TMPDIR}/tmp_${id_c}_CMC/predictedExpression.txt.gz OUTPUT_CMC/predict_PGC/200kb/${c}/
rm -r ${TMPDIR}/tmp_${id_c}_CMC/
