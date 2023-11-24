#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_CMC_BP_BM.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_CMC_BP_BM.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=1


module load R/3.5.3
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

###### PHESANT processed pehnotypes ######
fold_git=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
git_fold_ref=/psycl/g/mpsziller/lucia/castom-igex/refData/

# correct for covariates
${fold_git}pheno_association_combine_largeData_run.R \
	--names_file Blood_pressure Body_size_measures \
	--tscoreFold OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_tscore_res/ \
	--pathScoreFold_Reactome OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_reactome_res/ \
	--pathScoreFold_GO OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_GO_res/ \
	--outFold OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/ \
	--cov_corr T \
	--phenoAnn_file /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_PHESANTproc_CADrelatedpheno.txt \
	--reactome_file ${git_fold_ref}ReactomePathways.gmt \
	--GOterms_file ${git_fold_ref}GOterm_geneAnnotation_allOntologies.RData

