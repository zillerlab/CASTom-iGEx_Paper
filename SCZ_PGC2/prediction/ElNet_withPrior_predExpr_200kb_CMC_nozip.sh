#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/predExpr_c%a_CMC.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/predExpr_c%a_CMC.err
#SBATCH -N 1
#SBATCH --mem=80G
#SBATCH -t 48:00:00


module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/

id_c=${SLURM_ARRAY_TASK_ID}
readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

## copy from archive to home (do it from principal node)
#cp /archive/luciat/eQTL_PROJECT/INPUT_DATA_CMC/SCZ-PGC/Genotype_data/${c}.tar /home/luciat/eQTL_PROJECT/INPUT_DATA_CMC/SCZ-PGC/Genotype_data/
#tar zxf /home/luciat/eQTL_PROJECT/INPUT_DATA_CMC/SCZ-PGC/Genotype_data/${c}.tar  -C /home/luciat/eQTL_PROJECT/INPUT_DATA_CMC/SCZ-PGC/Genotype_data/
#rm /home/luciat/eQTL_PROJECT/INPUT_DATA_CMC/SCZ-PGC/Genotype_data/${c}.tar

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_CMC
cp /home/luciat/eQTL_PROJECT/INPUT_DATA_CMC/SCZ-PGC/Genotype_data/${c}/Genotype* ${TMPDIR}/tmp_${id_c}_CMC/
cp OUTPUT_CMC/train_CMC/200kb/res* ${TMPDIR}/tmp_${id_c}_CMC/
cp OUTPUT_CMC/train_CMC/*mtx ${TMPDIR}/tmp_${id_c}_CMC/

Rscript RSCRIPTS/SCRIPTS_v2/ElNet_withPrior_predictGeneExp_run.R --genoDat_file ${TMPDIR}/tmp_${id_c}_CMC/Genotype_dosage_ --covDat_file INPUT_DATA/Covariates/${c}.covariateMatrix.txt --outFold ${TMPDIR}/tmp_${id_c}_CMC/ --functR RSCRIPTS/SCRIPTS_v2/ElNet_withPrior_functions_run.R --outTrain_fold ${TMPDIR}/tmp_${id_c}_CMC/ --InfoFold ${TMPDIR}/tmp_${id_c}_CMC/ --no_zip T

gzip ${TMPDIR}/tmp_${id_c}_CMC/predictedExpression.txt
cp ${TMPDIR}/tmp_${id_c}_CMC/predictedExpression.txt.gz OUTPUT_CMC/predict_PGC/200kb/${c}/


rm -r ${TMPDIR}/tmp_${id_c}_CMC/
