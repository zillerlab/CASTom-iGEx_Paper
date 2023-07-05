#!/bin/bash

t=$1
type=$(awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv | awk -F "," '{print $2}')

if [[ "${type}" == "CAD" ]]
then 
	mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/CAD_GWAS_bin5e-2/devgeno0.01_testdevgeno0/
	outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/CAD_GWAS_bin5e-2/devgeno0.01_testdevgeno0/
	inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/CAD_GWAS_bin5e-2/
fi
if [[ "${type}" == "PGC" ]]
then 
	mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/PGC_GWAS_bin1e-2/devgeno0.01_testdevgeno0/
	outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/PGC_GWAS_bin1e-2/devgeno0.01_testdevgeno0/
	inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/PGC_GWAS_bin1e-2/
fi
if [[ "${type}"  == "noGWAS" ]]
then 
	mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/noGWAS/devgeno0.01_testdevgeno0/
	outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/noGWAS/devgeno0.01_testdevgeno0/
	inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/noGWAS/
fi

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/ 

${git_fold}Tscore_PathScore_diff_run.R \ 
	--covDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
	--outFold ${outFold} \
	--input_file ${inputFold}/predictedExpression.txt.gz \
	--GOterms_file ${ref_fold}GOterm_geneAnnotation_allOntologies.RData \
	--reactome_file ${ref_fold}ReactomePathways.gmt \
	--nFolds 40
