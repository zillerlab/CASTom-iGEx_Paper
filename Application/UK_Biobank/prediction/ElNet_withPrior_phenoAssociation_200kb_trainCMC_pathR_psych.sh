#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_pathR_psych_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_pathR_psych_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=10

module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/
git_fold = /psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
# correct for covariates
${git_fold}pheno_association_pathscore_largeData_run.R --inputInfoFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/pathScore_Reactome_info.RData --covDat_file INPUT_DATA/Covariates/covariatesMatrix_red.txt INPUT_DATA/Covariates/covariatesMatrix_red.txt INPUT_DATA/Covariates/covariatesMatrix_red.txt --phenoDat_file INPUT_DATA/Covariates/phenotypeMatrix_mixedpheno_Psychiatric.txt INPUT_DATA/Covariates/phenotypeMatrix_ICD9_Psychiatric.txt INPUT_DATA/Covariates/phenotypeMatrix_ICD10_Psychiatric.txt --names_file mixedpheno_Psychiatric ICD9_Psychiatric ICD10_Psychiatric  --inputFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Pathway_Reactome_scores_splitPath${SLURM_ARRAY_TASK_ID}.RData --outFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_reactome_res/pval_pathScore_Reactome_splitPath${SLURM_ARRAY_TASK_ID}_ --cov_corr T --sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix.txt --ncores 10 --phenoAnn_file INPUT_DATA/Covariates/phenotypeDescription_manualproc_ICD9-10_mixedpheno_Psychiatric.txt --functR ${git_fold}pheno_association_functions.R  --path_type Reactome
