#!/bin/bash


readarray -t tissues < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv)
readarray -t type_gwas < <(cut -d, -f2 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv)

for i in $(seq ${#type_gwas[@]})
do
	t=$(eval echo "\${tissues[${i}-1]}")
	type=$(eval echo "\${type_gwas[${i}-1]}")
	
	if [[ "${type}" == "CAD" ]]
	then 
		cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin5e-2/compare_PriLer_prediXcan_v6p.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_prediXcan_v6p.txt
		cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin5e-2/compare_PriLer_prediXcan_v7.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_prediXcan_v7.txt
		cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin5e-2/compare_PriLer_TWAS_v7.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_TWAS_v7.txt
		cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin5e-2/compare_PriLer_TWAS_v6p.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_TWAS_v6p.txt
	fi
	if [[ "${type}" == "PGC" ]]
	then 
		cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2/compare_PriLer_prediXcan_v6p.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_prediXcan_v6p.txt
                cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2/compare_PriLer_prediXcan_v7.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_prediXcan_v7.txt
                cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2/compare_PriLer_TWAS_v7.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_TWAS_v7.txt
		cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2/compare_PriLer_TWAS_v6p.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_TWAS_v6p.txt
	fi
	if [[ "${type}"  == "noGWAS" ]]
	then 
		cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/noGWAS/compare_PriLer_prediXcan_v6p.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_prediXcan_v6p.txt
                cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/noGWAS/compare_PriLer_prediXcan_v7.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_prediXcan_v7.txt
                cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/noGWAS/compare_PriLer_TWAS_v7.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_TWAS_v7.txt
		cp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/noGWAS/compare_PriLer_TWAS_v6p.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_TWAS_prediXcan/res_GTEx/${t}_compare_PriLer_TWAS_v6p.txt
	fi
done


