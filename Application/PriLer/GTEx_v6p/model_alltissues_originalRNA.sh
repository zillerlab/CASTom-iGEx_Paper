#!/bin/bash


readarray -t tissues < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv)
readarray -t type_gwas < <(cut -d, -f2 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv)

for i in $(seq ${#type_gwas[@]})
do
	t=$(eval echo "\${tissues[${i}-1]}")
	type=$(eval echo "\${type_gwas[${i}-1]}")
	mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}
	mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/no_train
	if [[ "${type}" == "CAD" ]]
	then 
		mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/CAD_GWAS_bin5e-2/
	fi
	if [[ "${type}" == "PGC" ]]
	then 
		mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/PGC_GWAS_bin1e-2/
	fi
	if [[ "${type}"  == "noGWAS" ]]
	then 
		mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/noGWAS/
	fi
done



