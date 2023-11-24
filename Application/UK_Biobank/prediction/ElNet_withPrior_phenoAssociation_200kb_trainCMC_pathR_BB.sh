#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_BB_pathR_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_BB_pathR_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=1

module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

fold_git=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

name_file=Blood_biochemistry
cov_file=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariatesMatrix_red.txt
dat_file=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeMatrix_Blood_biochemistry.txt



# correct for covariates
${fold_git}pheno_association_pathscore_largeData_run.R --inputInfoFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/pathScore_Reactome_info.RData --covDat_file ${cov_file[@]} --phenoDat_file ${dat_file[@]} --names_file ${name_file[@]}  --inputFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Pathway_Reactome_scores_splitPath${SLURM_ARRAY_TASK_ID}.RData --outFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_reactome_res/pval_pathScore_Reactome_splitPath${SLURM_ARRAY_TASK_ID}_ --cov_corr T --sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix_red.txt --ncores 1 --phenoAnn_file /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_PHESANTproc_CADrelatedpheno.txt --functR ${fold_git}pheno_association_functions.R  --path_type Reactome