#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_pathR_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_pathR_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=5G
#SBATCH --cpus-per-task=10

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

id_t=$1
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
mkdir -p OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/Association_reactome_res/

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/

name_file=(ICD10_Anaemia ICD10_Circulatory_system ICD10_Endocrine ICD10_Respiratory_system)

cov_file=(INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt)

dat_file=(INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeMatrix_ICD10_Anaemia.txt INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeMatrix_ICD10_Circulatory_system.txt INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeMatrix_ICD10_Endocrine.txt INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeMatrix_ICD10_Respiratory_system.txt)

# correct for covariates
${git_fold}pheno_association_pathscore_largeData_run.R \
	--inputInfoFile ${fold}pathScore_Reactome_info.RData \
	--covDat_file ${cov_file[@]} \
	--phenoDat_file ${dat_file[@]} \
	--names_file ${name_file[@]} \
	--inputFile ${fold}Pathway_Reactome_scores_splitPath${SLURM_ARRAY_TASK_ID}.RData \
	--outFile ${fold}Association_reactome_res/pval_pathScore_Reactome_splitPath${SLURM_ARRAY_TASK_ID}_ \
	--cov_corr T \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--ncores 10 \
	--phenoAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_manualproc_ICD9-10_OPCS4.txt \
	--functR ${git_fold}pheno_association_functions.R \
	--path_type Reactome

