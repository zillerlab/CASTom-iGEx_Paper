#!/bin/bash

t=$1

f=/psycl/g/mpsziller/lucia/
mkdir -p ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb
git_fold=${f}castom-igex/Software/model_training/

for i in $(seq 22)
do
	echo 'chr' $i

	${git_fold}PriLer_part1_run.R \
		--curChrom chr$i \
		--covDat_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
		--genoDat_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_dosage_ \
		--geneExp_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/RNAseq_filt.txt \
		--ncores 30 \
		--outFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/ \
		--InfoFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/ \
		--functR ${git_fold}PriLer_functions.R 
done
