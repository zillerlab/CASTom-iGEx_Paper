#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/phenoAssociation_customPath_c%a_CMC.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/phenoAssociation_customPath_c%a_CMC.err
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH -t 24:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_prediction/

id_c=${SLURM_ARRAY_TASK_ID}
readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_CMC
cp OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/* ${TMPDIR}/tmp_${id_c}_CMC/
cp OUTPUT_CMC/train_CMC/200kb/resPrior_regEval_allchr.txt ${TMPDIR}/tmp_${id_c}_CMC/
cp refData/CMC_GeneSets_Hypothesis-driven-for-Enrichement.RData ${TMPDIR}/tmp_${id_c}_CMC/

${git_fold}pheno_association_smallData_customPath_run.R \
	--covDat_file INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt \
	--phenoDat_file INPUT_DATA/Covariates/${c}.phenoMatrix_old.txt \
	--geneAnn_file ${TMPDIR}/tmp_${id_c}_CMC/resPrior_regEval_allchr.txt \
	--inputFold ${TMPDIR}/tmp_${id_c}_CMC/ \
	--outFold ${TMPDIR}/tmp_${id_c}_CMC/ \
	--pathwayStructure_file ${TMPDIR}/tmp_${id_c}_CMC/CMC_GeneSets_Hypothesis-driven-for-Enrichement.RData \
	--cov_corr T \
	--functR ${git_fold}pheno_association_functions.R \
	--sampleAnn_file INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt \
	--names_file SCZ_pheno \
	--phenoAnn_file INPUT_DATA/Covariates/phenotypeDescription_PGCcohorts.csv \
	--geneSetName CMC_GeneSets 

cp ${TMPDIR}/tmp_${id_c}_CMC/pval*RData OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/

rm -r ${TMPDIR}/tmp_${id_c}_CMC/
