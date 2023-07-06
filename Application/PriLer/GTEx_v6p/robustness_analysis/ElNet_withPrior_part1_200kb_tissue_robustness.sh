#!/bin/bash

t=$1
id=$2

mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/robustness_analysis/rep${id}/

outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/robustness_analysis/rep${id}/
covFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/robustness_analysis/
genFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/
rnaFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_training/


for i in $(seq 22)
do
	echo 'chr' $i

	Rscript ${git_fold}PriLer_part1_run.R  --curChrom chr$i --covDat_file ${covFold}covariates_EuropeanSamples_rep${id}.txt --genoDat_file ${genFold}Genotype_dosage_ --geneExp_file ${rnaFold}RNAseq_filt.txt --ncores 30 --outFold ${outFold} --InfoFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/ --functR ${git_fold}PriLer_functions.R 

done

