#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_pathR_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_pathR_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=10


id_t=$1

module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

readarray -t tissues < /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/Tissue_noGWAS
t=$(eval echo "\${tissues[${id_t}-1]}")

name_file=Blood_biochemistry
cov_file=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariatesMatrix_red.txt
dat_file=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeMatrix_Blood_biochemistry.txt

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
# correct for covariates
${git_fold}pheno_association_pathscore_largeData_run.R --inputInfoFile OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/pathScore_Reactome_info.RData --covDat_file ${cov_file[@]} --phenoDat_file ${dat_file[@]} --names_file ${name_file[@]}  --inputFile OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/Pathway_Reactome_scores_splitPath${SLURM_ARRAY_TASK_ID}.RData --outFile OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/Association_reactome_res/pval_pathScore_Reactome_splitPath${SLURM_ARRAY_TASK_ID}_ --cov_corr T --sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix.txt --ncores 10 --phenoAnn_file INPUT_DATA/Covariates/phenotypeDescription_PHESANTproc.txt --functR ${git_fold}pheno_association_functions.R   --path_type Reactome

