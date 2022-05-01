#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/phenoAssociation_c%a_%x_GTEx.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/phenoAssociation_c%a_%x_GTEx.err
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH -t 24:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/

id_c=${SLURM_ARRAY_TASK_ID}
readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

id_t=$1
readarray -t tissues < /home/luciat/eQTL_PROJECT/OUTPUT_GTEx/Tissue_PGCgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
cp OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/* ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
cp OUTPUT_GTEx/train_GTEx/${t}/200kb/PGC_GWAS_bin1e-2/resPrior_regEval_allchr.txt ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
cp refData/ReactomePathways.gmt ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
cp refData/GOterm_geneAnnotation_allOntologies.RData ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/

Rscript RSCRIPTS/SCRIPTS_v2/AssociationAnalysis_PredVSPheno_v3_run.R --covDat_file INPUT_DATA/Covariates/${c}.covariateMatrix.txt --phenoDat_file INPUT_DATA/Covariates/${c}.phenoMatrix.txt --geneAnn_file ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/resPrior_regEval_allchr.txt --inputFold ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/ --outFold ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/ --GOterms_file ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/GOterm_geneAnnotation_allOntologies.RData --reactome_file ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/ReactomePathways.gmt --cov_corr T --functR RSCRIPTS/SCRIPTS_v2/AssociationAnalysis_functions_run.R --sampleAnn_file INPUT_DATA/Covariates/${c}.covariateMatrix.txt --names_file SCZ_pheno --phenoAnn_file INPUT_DATA/Covariates/phenotypeDescription_PGCcohorts.csv

cp ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/pval*RData OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/

rm -r ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
