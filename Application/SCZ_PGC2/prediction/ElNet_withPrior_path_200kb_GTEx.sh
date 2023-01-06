#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/pathDiff_%x_c%a_GTEx.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/pathDiff_%x_c%a_GTEx.err
#SBATCH -N 1
#SBATCH --mem=40G
#SBATCH -t 48:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_prediction/

id_c=${SLURM_ARRAY_TASK_ID}
readarray -t cohorts < INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

readarray -t tissues < OUTPUT_GTEx/Tissue_PGCgwas
id_t=$1
t=$(eval echo "\${tissues[${id_t}-1]}")

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx
cp OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/predictedExpression.txt.gz ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
cp refData/ReactomePathways.gmt ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
cp refData/GOterm_geneAnnotation_allOntologies.RData ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/

${git_fold}Tscore_PathScore_diff_run.R \
	--covDat_file INPUT_DATA/Covariates/${c}.covariateMatrix.txt \
	--input_file ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/predictedExpression.txt.gz \
	--outFold ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/ \
	--nFolds 40 \
	--GOterms_file ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/GOterm_geneAnnotation_allOntologies.RData \
	--reactome_file ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/ReactomePathways.gmt

cp ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/Pathway* OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/
cp ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/predictedTscores.txt OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/

rm -r ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
