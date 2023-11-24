#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/pheno_BCratio_pathGO_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/pheno_BCratio_pathGO_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=10

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

fold=OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/
pheno_fold=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/

# correct for covariates
${git_fold}pheno_association_pathscore_largeData_run.R \
	--inputInfoFile ${fold}pathScore_GO_info.RData \
	--covDat_file ${pheno_fold}covariatesMatrix_red_latestW.txt \
	--phenoDat_file ${pheno_fold}phenotypeMatrix_Blood_count_ratio.txt \
	--names_file Blood_count_ratio \
	--inputFile ${fold}Pathway_GO_scores_splitPath${SLURM_ARRAY_TASK_ID}.RData \
	--outFile ${fold}Association_GO_res/pval_pathScore_GO_splitPath${SLURM_ARRAY_TASK_ID}_ \
	--cov_corr T \
	--sampleAnn_file ${pheno_fold}covariatesMatrix_red_latestW.txt \
	--ncores 10 \
	--phenoAnn_file ${pheno_fold}phenotypeDescription_ratioBC_PHESANTproc.txt \
	--functR ${git_fold}pheno_association_functions.R \
	--path_type GO \
