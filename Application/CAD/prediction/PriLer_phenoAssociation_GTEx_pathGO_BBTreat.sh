#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_BBTreat_pathGO_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_BBTreat_pathGO_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=2

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

id_t=$1
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
in_fold=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/

# correct for covariates
${git_fold}pheno_association_pathscore_largeData_run.R \
	--inputInfoFile ${fold}pathScore_GO_info.RData \
	--covDat_file ${in_fold}covariateMatrix_withMedication.txt ${in_fold}covariateMatrix_withMedication.txt \
	--phenoDat_file ${in_fold}phenotypeMatrix_Blood_biochemistry.txt ${in_fold}phenotypeMatrix_Blood_count.txt \
	--names_file Blood_biochemistry_withMed Blood_count_withMed \
	--inputFile ${fold}Pathway_GO_scores_splitPath${SLURM_ARRAY_TASK_ID}.RData \
	--outFile ${fold}Association_GO_res/pval_pathScore_GO_splitPath${SLURM_ARRAY_TASK_ID}_ \
	--cov_corr T \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--ncores 2 \
	--phenoAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_PHESANTproc_CADrelatedpheno.txt \
	--functR ${git_fold}pheno_association_functions.R \
	--path_type GO

