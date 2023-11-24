#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_BP_BM_pathGO_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_BP_BM_pathGO_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=5G
#SBATCH --cpus-per-task=10

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

fold_git=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

name_file=(Blood_pressure Body_size_measures)
CAD_fold=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/
cov_file=(/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariatesMatrix_red.txt /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariatesMatrix_red.txt)
dat_file=(${CAD_fold}phenotypeMatrix_Blood_pressure.txt ${CAD_fold}phenotypeMatrix_Body_size_measures.txt)


# correct for covariates
${fold_git}pheno_association_pathscore_largeData_run.R \
	--inputInfoFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/pathScore_GO_info.RData \
	--covDat_file ${cov_file[@]} \
	--phenoDat_file ${dat_file[@]} \
	--names_file ${name_file[@]}  \
	--inputFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Pathway_GO_scores_splitPath${SLURM_ARRAY_TASK_ID}.RData \
	--outFile OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_GO_res/pval_pathScore_GO_splitPath${SLURM_ARRAY_TASK_ID}_ \
	--cov_corr T \
	--sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix_red.txt \
	--ncores 2 \
	--phenoAnn_file ${CAD_fold}phenotypeDescription_PHESANTproc_CADrelatedpheno.txt \
	--functR ${fold_git}pheno_association_functions.R \
	--path_type GO

