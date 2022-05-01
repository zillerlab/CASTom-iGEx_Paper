#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/meta_analysis_CMC.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/meta_analysis_CMC.err
#SBATCH -N 1
#SBATCH --mem=40G
#SBATCH -t 48:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/

readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
name_cohorts=${cohorts[@]}

file_res=()
file_pheno=()

mkdir -p ${TMPDIR}/tmp_CMC
cp refData/ReactomePathways.gmt ${TMPDIR}/tmp_CMC/
cp refData/GOterm_geneAnnotation_allOntologies.RData ${TMPDIR}/tmp_CMC/


for c in ${name_cohorts[@]}
do
	echo ${c}
	file_res+=(OUTPUT_CMC/predict_PGC/200kb/${c}/devgeno0.01_testdevgeno0/pval_SCZ_pheno_covCorr.RData)
	file_pheno+=(INPUT_DATA/Covariates/${c}.phenoMatrix.txt)
done

# correct for covariates
Rscript RSCRIPTS/SCRIPTS_v2/MetaAnalysis_Association_v2_run.R --res_cohorts ${file_res[@]} --phenoDatFile_cohorts ${file_pheno[@]} --phenoName Dx --outFold ${TMPDIR}/tmp_CMC --GOterms_file ${TMPDIR}/tmp_CMC/GOterm_geneAnnotation_allOntologies.RData --reactome_file ${TMPDIR}/tmp_CMC/ReactomePathways.gmt --cov_corr T --name_cohort ${name_cohorts[@]}

cp ${TMPDIR}/tmp_CMC/phenoInfo*txt OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/
cp ${TMPDIR}/tmp_CMC/pval*RData OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/

rm -r ${TMPDIR}/tmp_CMC/
