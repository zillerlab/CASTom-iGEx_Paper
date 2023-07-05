#!/bin/bash

t=$1
type=$(awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv | awk -F "," '{print $2}')
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

if [[ "${type}" == "CAD" ]]
then 
	outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/CAD_GWAS_bin5e-2/
	inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin5e-2/
fi
if [[ "${type}" == "PGC" ]]
then 
	outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/PGC_GWAS_bin1e-2/
	inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2/
fi
if [[ "${type}"  == "noGWAS" ]]
then 
	outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/predict_GTEx/${t}/noGWAS/
	inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/noGWAS/
fi

${git_fold}PriLer_predictGeneExp_run.R \ 
	--genoDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_dosage_ \
	--covDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
	--outFold ${outFold} \
	--outTrain_fold ${inputFold} \
	--InfoFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/
