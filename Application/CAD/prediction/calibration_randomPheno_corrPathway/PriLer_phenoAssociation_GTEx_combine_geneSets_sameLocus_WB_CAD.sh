#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_geneSets_locus_WB.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_geneSets_locus_WB.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

t=Whole_Blood
name_pheno=CAD

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

# correct for covariates
Rscript ${git_fold}pheno_association_combine_largeData_customPath_run.R \
	--names_file CAD \
	--tscoreFold ${fold}Association_tscore_res/ \
	--pathScoreFold ${fold}Association_geneSets_sameLocus_res/ \
	--outFold ${fold} \
	--cov_corr T \
	--phenoAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_CAD.txt \
	--pathwayCustom_file ${fold}/geneSets_sameLocus_sameSign.RData \
	--pathwayCustom_name geneSets_sameLocus

	



