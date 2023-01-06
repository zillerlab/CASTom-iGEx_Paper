#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/meta_analysis_t%a_GTEx.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/meta_analysis_t%a_GTEx.err
#SBATCH -N 1
#SBATCH --mem=40G
#SBATCH -t 48:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_prediction/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < /home/luciat/eQTL_PROJECT/OUTPUT_GTEx/Tissue_PGCgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

mkdir -p OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/

readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
name_cohorts=${cohorts[@]}

file_res=()
file_pheno=()

mkdir -p ${TMPDIR}/tmp_GTEx_${id_t}/
cp refData/ReactomePathways.gmt ${TMPDIR}/tmp_GTEx_${id_t}/
cp refData/GOterm_geneAnnotation_allOntologies.RData ${TMPDIR}/tmp_GTEx_${id_t}/


for c in ${name_cohorts[@]}
do
	echo ${c}
	file_res+=(OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/pval_SCZ_pheno_covCorr.RData)
	file_pheno+=(INPUT_DATA/Covariates/${c}.phenoMatrix.txt)
done

# correct for covariates
${git_fold}pheno_association_metaAnalysis_run.R \
	--res_cohorts ${file_res[@]} \
	--phenoDatFile_cohorts ${file_pheno[@]} \
	--phenoName Dx \
	--outFold ${TMPDIR}/tmp_GTEx_${id_t}/ \
	--GOterms_file ${TMPDIR}/tmp_GTEx_${id_t}/GOterm_geneAnnotation_allOntologies.RData \
	--reactome_file ${TMPDIR}/tmp_GTEx_${id_t}/ReactomePathways.gmt \
	--cov_corr T \
	--name_cohort ${name_cohorts[@]}

cp ${TMPDIR}/tmp_GTEx_${id_t}/phenoInfo*txt OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/
cp ${TMPDIR}/tmp_GTEx_${id_t}/pval*RData OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/

rm -r ${TMPDIR}/tmp_GTEx_${id_t}
