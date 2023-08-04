#!/bin/bash

t=$1

f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/
mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/200kb

for i in $(seq 22)
do
	echo 'chr' $i

	${git_fold}Software/model_training/PriLer_part1_run.R  \
		--curChrom chr$i \
		--covDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
		--genoDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/Genotype_data/Genotype_dosage_caucasian_maf001_info06_ \
		--geneExp_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/RNAseq_data/${t}/RNAseq_filt.txt \
		--ncores 30 \
		--outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/200kb/ \
		--InfoFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/ \
		--functR ${git_fold}Software/model_training/PriLer_functions_run.R 

done

