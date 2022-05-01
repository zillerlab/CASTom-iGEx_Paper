#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/phenoAssociation_customPath_%x_c%a.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/phenoAssociation_customPath_%x_c%a.err
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH -t 24:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/

id_c=${SLURM_ARRAY_TASK_ID}
readarray -t cohorts < INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

git_fold=/home/luciat/castom-igex/Software/model_prediction/
file_path_name=$1
path_name=$2
tissue=$3

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_${tissue}
cp OUTPUT_GTEx/predict_PGC/${tissue}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt ${TMPDIR}/tmp_${id_c}_${tissue}/
cp OUTPUT_GTEx/predict_PGC/${tissue}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/Pathway_${path_name}_scores*txt ${TMPDIR}/tmp_${id_c}_${tissue}/
cp OUTPUT_GTEx/train_GTEx/${tissue}/200kb/PGC_GWAS_bin1e-2/resPrior_regEval_allchr.txt ${TMPDIR}/tmp_${id_c}_${tissue}/
cp /home/luciat/priler_project/refData/${file_path_name} ${TMPDIR}/tmp_${id_c}_${tissue}/

${git_fold}pheno_association_smallData_customPath_run.R \
	--covDat_file INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt \
	--phenoDat_file INPUT_DATA/Covariates/${c}.phenoMatrix_old.txt \
	--geneAnn_file ${TMPDIR}/tmp_${id_c}_${tissue}/resPrior_regEval_allchr.txt \
	--inputFold ${TMPDIR}/tmp_${id_c}_${tissue}/ \
	--outFold ${TMPDIR}/tmp_${id_c}_${tissue}/ \
	--pathwayStructure_file ${TMPDIR}/tmp_${id_c}_${tissue}/${file_path_name} \
	--cov_corr T \
	--functR ${git_fold}pheno_association_functions.R \
	--sampleAnn_file INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt \
	--names_file SCZ_pheno \
	--phenoAnn_file INPUT_DATA/Covariates/phenotypeDescription_PGCcohorts.csv \
	--geneSetName ${path_name} 

cp ${TMPDIR}/tmp_${id_c}_${tissue}/pval*RData OUTPUT_GTEx/predict_PGC/${tissue}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/

rm -r ${TMPDIR}/tmp_${id_c}_${tissue}/

