#!/bin/bash

t=$1
type=$(awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv | awk -F "," '{print $2}')

if [[ "${type}" == "CAD" ]]
then 
	Fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/CAD_GWAS_bin5e-2/
fi
if [[ "${type}" == "PGC" ]]
then 
	Fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/PGC_GWAS_bin1e-2/
fi
if [[ "${type}"  == "noGWAS" ]]
then 
	Fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/noGWAS/
fi

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/ 

${git_fold}Tscore_PathScore_diff_run.R \
	--originalRNA T \
	--covDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
	--outFold ${Fold} \
	--input_file ${Fold}/RNAseq_filt_covCorrected.txt \
	--GOterms_file ${ref_fold}GOterm_geneAnnotation_allOntologies.RData \
	--reactome_file ${ref_fold}ReactomePathways.gmt \
	--nFolds 40
