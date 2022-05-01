#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/meta_analysis_customPath_CMC.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/meta_analysis_customPath_CMC.err
#SBATCH -N 1
#SBATCH --mem=20G
#SBATCH -t 48:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_prediction/

readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
name_cohorts=${cohorts[@]}

file_res=()
file_pheno=()

mkdir -p ${TMPDIR}/tmp_CMC
cp refData/CMC_GeneSets_Hypothesis-driven-for-Enrichement.RData ${TMPDIR}/tmp_CMC/

for c in ${name_cohorts[@]}
do
	echo ${c}
	file_res+=(OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/pval_SCZ_pheno_covCorr_customPath_CMC_GeneSets.RData)
	file_pheno+=(INPUT_DATA/Covariates/${c}.phenoMatrix_old.txt)
done

# correct for covariates
${git_fold}pheno_association_customPath_metaAnalysis_run.R \
	--res_cohorts ${file_res[@]} \
	--phenoDatFile_cohorts ${file_pheno[@]} \
	--phenoName Dx \
	--outFold ${TMPDIR}/tmp_CMC \
	--pathwayStructure_file ${TMPDIR}/tmp_CMC/CMC_GeneSets_Hypothesis-driven-for-Enrichement.RData \
	--geneSetName CMC_GeneSets \
	--cov_corr T \
	--name_cohort ${name_cohorts[@]} 

cp ${TMPDIR}/tmp_CMC/phenoInfo*txt OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/
cp ${TMPDIR}/tmp_CMC/pval*RData OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/

rm -r ${TMPDIR}/tmp_CMC/
