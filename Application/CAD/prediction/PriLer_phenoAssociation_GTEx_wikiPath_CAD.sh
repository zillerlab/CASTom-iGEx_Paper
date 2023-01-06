#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_pathwiki_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_pathwiki_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=10

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

id_t=$1
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
mkdir -p OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/Association_WikiPath2019Human_res/

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/

# correct for covariates
${git_fold}pheno_association_pathscore_largeData_run.R \
	--inputInfoFile ${fold}pathScore_WikiPath2019Human_info.RData \
	--covDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--phenoDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenoMatrix_updateCADHARD.txt \
	--names_file CAD \
	--inputFile ${fold}Pathway_WikiPath2019Human_scores_splitPath1.RData \
	--outFile ${fold}Association_WikiPath2019Human_res/pval_pathScore_WikiPath2019Human_splitPath1_ \
	--cov_corr T \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--ncores 10 \
	--phenoAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_CAD.txt \
	--functR ${git_fold}pheno_association_functions.R \
	--path_type WikiPath2019Human

