#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/meta_analysis_customPath_%x_CMC.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/meta_analysis_customPath_%x_CMC.err
#SBATCH -N 1
#SBATCH --mem=20G
#SBATCH -t 48:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/

readarray -t cohorts < INPUT_DATA/SCZ_cohort_names
name_cohorts=${cohorts[@]}

git_fold=/home/luciat/castom-igex/Software/model_prediction/
file_path_name=$1
path_name=$2
fold_out=OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/

file_res=()
file_pheno=()

mkdir -p ${TMPDIR}/tmp_CMC
cp /home/luciat/priler_project/refData/${file_path_name} ${TMPDIR}/tmp_CMC/

for c in ${name_cohorts[@]}
do
	echo ${c}
	file_res+=(OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/pval_SCZ_pheno_covCorr_customPath_${path_name}.RData)
	file_pheno+=(INPUT_DATA/Covariates/${c}.phenoMatrix_old.txt)
done

# correct for covariates
${git_fold}pheno_association_customPath_metaAnalysis_run.R \
	--res_cohorts ${file_res[@]} \
	--phenoDatFile_cohorts ${file_pheno[@]} \
	--phenoName Dx \
	--outFold ${TMPDIR}/tmp_CMC/ \
	--pathwayStructure_file ${TMPDIR}/tmp_CMC/${file_path_name} \
	--geneSetName ${path_name} \
	--cov_corr T \
	--name_cohort ${name_cohorts[@]}

cp ${TMPDIR}/tmp_CMC/phenoInfo*txt ${fold_out}
cp ${TMPDIR}/tmp_CMC/pval*RData ${fold_out}

rm -r ${TMPDIR}/tmp_CMC/
