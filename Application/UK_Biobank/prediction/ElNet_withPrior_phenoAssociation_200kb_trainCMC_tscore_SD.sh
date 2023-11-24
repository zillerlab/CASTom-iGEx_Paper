#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_SD_tscore_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_SD_tscore_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=5G
#SBATCH --cpus-per-task=10

module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

fold_git=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

name_file=$(awk '{print $1}' INPUT_DATA/Covariates/match_cov_pheno_SchunkertApp.txt)
name_file=(${name_file// / })

cov_file=$(awk '{print $3}' INPUT_DATA/Covariates/match_cov_pheno_SchunkertApp.txt)
cov_file=(${cov_file// / })

dat_file=$(awk '{print $2}' INPUT_DATA/Covariates/match_cov_pheno_SchunkertApp.txt)
dat_file=(${dat_file// / })


# correct for covariates
${fold_git}pheno_association_tscore_largeData_run.R --inputInfoFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/tscore_info.RData --covDat_file ${cov_file[@]} --phenoDat_file ${dat_file[@]} --names_file ${name_file[@]}  --inputFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/predictedTscores_splitGenes${SLURM_ARRAY_TASK_ID}.RData --outFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_tscore_res/pval_tscore_splitGene${SLURM_ARRAY_TASK_ID}_ --cov_corr T --sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix_red.txt --ncores 10 --phenoAnn_file /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_PHESANTproc_CADrelatedpheno.txt --functR ${fold_git}pheno_association_functions.R --split_gene_id ${SLURM_ARRAY_TASK_ID}  
