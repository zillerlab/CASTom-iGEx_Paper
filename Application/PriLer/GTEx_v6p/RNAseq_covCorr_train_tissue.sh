#!/bin/bash

t=$1
type=$(awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv | awk -F "," '{print $2}')

if [[ "${type}" == "CAD" ]]
then 
	outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/CAD_GWAS_bin5e-2/
	inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin5e-2/
fi
if [[ "${type}" == "PGC" ]]
then 
	outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/PGC_GWAS_bin1e-2/
	inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2/
fi
if [[ "${type}"  == "noGWAS" ]]
then 
	outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/noGWAS/
	inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/noGWAS/
fi

Rscript RNAseq_covCorrected_trainOpt_run.R \
--covFile /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
--outFold ${outFold} \
--exprDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/ \
--regCoeff_cov ${inputFold}/resPrior_regCoeffCov_allchr.txt