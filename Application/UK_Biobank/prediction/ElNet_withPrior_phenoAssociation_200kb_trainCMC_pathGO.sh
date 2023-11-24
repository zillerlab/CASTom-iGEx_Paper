#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_pathGO_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_pathGO_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=9G
#SBATCH --cpus-per-task=10

module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

name_file=$(awk '{print $1}' INPUT_DATA/Covariates/match_cov_pheno.txt)
name_file=(${name_file// / })

cov_file=$(awk '{print $3}' INPUT_DATA/Covariates/match_cov_pheno.txt)
cov_file=(${cov_file// / })
cov_file=( "${cov_file[@]/#/INPUT_DATA/Covariates/}" )

dat_file=$(awk '{print $2}' INPUT_DATA/Covariates/match_cov_pheno.txt)
dat_file=(${dat_file// / })
dat_file=( "${dat_file[@]/#/INPUT_DATA/Covariates/}" )

git_fold = /psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
# correct for covariates
${git_fold}pheno_association_pathscore_largeData_run.R --inputInfoFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/pathScore_GO_info.RData --covDat_file ${cov_file[@]} --phenoDat_file ${dat_file[@]} --names_file ${name_file[@]}  --inputFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Pathway_GO_scores_splitPath${SLURM_ARRAY_TASK_ID}.RData --outFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_GO_res/pval_pathScore_GO_splitPath${SLURM_ARRAY_TASK_ID}_ --cov_corr T --sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix.txt --ncores 10 --phenoAnn_file INPUT_DATA/Covariates/phenotypeDescription_PHESANTproc.txt --functR ${git_fold}pheno_association_functions.R  --path_type GO
