#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_BCratio_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_BCratio_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/

fold=OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/
pheno_fold=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/

# correct for covariates
${git_fold}pheno_association_combine_largeData_run.R \
	--names_file Blood_count_ratio \
	--tscoreFold ${fold}Association_tscore_res/ \
	--pathScoreFold_Reactome ${fold}/Association_reactome_res/ \
	--pathScoreFold_GO ${fold}Association_GO_res/ \
	--outFold ${fold} \
	--cov_corr T \
	--phenoAnn_file ${pheno_fold}phenotypeDescription_ratioBC_PHESANTproc.txt \
	--reactome_file ${ref_fold}ReactomePathways.gmt \
	--GOterms_file ${ref_fold}GOterm_geneAnnotation_allOntologies.RData \
