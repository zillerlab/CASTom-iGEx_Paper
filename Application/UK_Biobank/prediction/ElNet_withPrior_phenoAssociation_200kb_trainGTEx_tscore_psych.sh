#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_tscore_psych_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_tscore_psych_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=9G
#SBATCH --cpus-per-task=10


id_t=$1
readarray -t tissues < /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/Tissue_noGWAS
t=$(eval echo "\${tissues[${id_t}-1]}")


module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

# correct for covariates
${git_fold}pheno_association_tscore_largeData_run.R --inputInfoFile OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/tscore_info.RData --covDat_file INPUT_DATA/Covariates/covariatesMatrix_red.txt INPUT_DATA/Covariates/covariatesMatrix_red.txt INPUT_DATA/Covariates/covariatesMatrix_red.txt --phenoDat_file INPUT_DATA/Covariates/phenotypeMatrix_mixedpheno_Psychiatric.txt INPUT_DATA/Covariates/phenotypeMatrix_ICD9_Psychiatric.txt INPUT_DATA/Covariates/phenotypeMatrix_ICD10_Psychiatric.txt --names_file mixedpheno_Psychiatric ICD9_Psychiatric ICD10_Psychiatric --inputFile OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/predictedTscores_splitGenes${SLURM_ARRAY_TASK_ID}.RData --outFile OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/Association_tscore_res/pval_tscore_splitGene${SLURM_ARRAY_TASK_ID}_ --cov_corr T --sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix.txt --ncores 10 --phenoAnn_file INPUT_DATA/Covariates/phenotypeDescription_manualproc_ICD9-10_mixedpheno_Psychiatric.txt --functR ${git_fold}pheno_association_functions.R  
