#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_%x_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_%x_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
cohort=$1

id_t=${SLURM_ARRAY_TASK_ID}

readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/ 
git_ref=/psycl/g/mpsziller/lucia/castom-igex/refData/

# correct for covariates
Rscript ${git_fold}pheno_association_smallData_run.R \
	--covDat_file INPUT_DATA_GTEx/CAD/Covariates/${cohort}/covariateMatrix.txt \
	--phenoDat_file INPUT_DATA_GTEx/CAD/Covariates/${cohort}/phenoMatrix.txt \
	--phenoAnn_file INPUT_DATA_GTEx/CAD/Covariates/phenotypeDescription_SchunkertCohorts.csv \
	--geneAnn_file OUTPUT_GTEx/train_GTEx/${t}/200kb/CAD_GWAS_bin5e-2/resPrior_regEval_allchr.txt \
	--inputFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/devgeno0.01_testdevgeno0/ \
	--outFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/devgeno0.01_testdevgeno0/ \
	--GOterms_file ${git_ref}GOterm_geneAnnotation_allOntologies.RData \
	--reactome_file ${git_ref}ReactomePathways.gmt \
	--cov_corr T \
	--functR ${git_fold}pheno_association_functions.R \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/${cohort}/covariateMatrix.txt \
	--names_file CAD_pheno

