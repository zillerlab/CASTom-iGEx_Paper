#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/corr_geneSet_c%a_CMC_LoF.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/corr_geneSet_c%a_CMC_LoF.err
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH -t 24:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/

id_c=${SLURM_ARRAY_TASK_ID}
readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

git_fold=/home/luciat/priler_project/

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_CMC
cp OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt ${TMPDIR}/tmp_${id_c}_CMC/
cp OUTPUT_CMC/train_CMC/200kb/resPrior_regEval_allchr.txt ${TMPDIR}/tmp_${id_c}_CMC/

Rscript /home/luciat/eQTL_PROJECT/SCRIPTS/prediction/corr_customGeneList_run.R \
	--gene_list INPUT_DATA/list_genes_SCZLoF.txt \
	--geneAnn_file ${TMPDIR}/tmp_${id_c}_CMC/resPrior_regEval_allchr.txt \
	--inputFold ${TMPDIR}/tmp_${id_c}_CMC/ \
	--outFold ${TMPDIR}/tmp_${id_c}_CMC/ \
	--functR ${git_fold}Software/model_prediction/pheno_association_functions.R \
	--sampleAnn_file INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt \
	--geneSetName SCZ_LoF_GeneSets

cp ${TMPDIR}/tmp_${id_c}_CMC/cor_custom_geneList_*RData OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/

rm -r ${TMPDIR}/tmp_${id_c}_CMC/

