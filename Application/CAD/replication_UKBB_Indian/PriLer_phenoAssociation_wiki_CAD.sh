#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_Indian_wiki_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_Indian_wiki_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}

readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
path_file=/psycl/g/mpsziller/lucia/castom-igex/refData/WikiPathways_2019_Human.RData


${git_fold}pheno_association_smallData_customPath_run.R \
	--covDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB_other_ancestry/covariateMatrix_latestW_202202_Indian.txt \
	--phenoDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB_other_ancestry/phenotypeMatrix_CAD_Indian.txt \
	--geneAnn_file OUTPUT_GTEx/train_GTEx/${t}/200kb/CAD_GWAS_bin5e-2/resPrior_regEval_allchr.txt \
	--inputFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB_other_ancestry/devgeno0.01_testdevgeno0/ \
	--outFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB_other_ancestry/devgeno0.01_testdevgeno0/ \
	--pathwayStructure_file ${path_file} \
	--cov_corr T \
	--functR ${git_fold}pheno_association_functions.R \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB_other_ancestry/covariateMatrix_latestW_202202_Indian.txt \
	--names_file CAD_pheno \
	--phenoAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB_other_ancestry/phenotypeDescription_CAD_Indian.txt \
	--geneSetName WikiPath2019Human

