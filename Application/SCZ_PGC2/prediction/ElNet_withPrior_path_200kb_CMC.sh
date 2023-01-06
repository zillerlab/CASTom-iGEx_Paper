#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/pathDiff_c%a_CMC.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/pathDiff_c%a_CMC.err
#SBATCH -N 1
#SBATCH --mem=40G
#SBATCH -t 48:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_prediction/

id_c=${SLURM_ARRAY_TASK_ID}
readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_CMC
cp OUTPUT_CMC/predict_PGC/200kb/${c}/predictedExpression.txt.gz ${TMPDIR}/tmp_${id_c}_CMC/
cp refData/ReactomePathways.gmt ${TMPDIR}/tmp_${id_c}_CMC/
cp refData/GOterm_geneAnnotation_allOntologies.RData ${TMPDIR}/tmp_${id_c}_CMC/

${git_fold}Tscore_PathScore_diff_run.R \
	--covDat_file INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt \
	--input_file ${TMPDIR}/tmp_${id_c}_CMC/predictedExpression.txt.gz \
	--outFold ${TMPDIR}/tmp_${id_c}_CMC/ \
	--nFolds 40 \
	--GOterms_file ${TMPDIR}/tmp_${id_c}_CMC/GOterm_geneAnnotation_allOntologies.RData \
	--reactome_file ${TMPDIR}/tmp_${id_c}_CMC/ReactomePathways.gmt

cp ${TMPDIR}/tmp_${id_c}_CMC/Pathway* OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/
cp ${TMPDIR}/tmp_${id_c}_CMC/predictedTscores.txt OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/

rm -r ${TMPDIR}/tmp_${id_c}_CMC/
