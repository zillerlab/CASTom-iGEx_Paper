#!/bin/bash

t=$1

f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/Software/model_training/
priorInd=$(awk '{print $1}' ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/priorName_nogwas_withIndex.txt)

for i in $(seq 22)
do
	echo 'chr' $i

	${git_fold}PriLer_part4_run.R \  
		--curChrom chr${i} \
		--covDat_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
		--genoDat_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchUKBB/Genotype_data/Genotype_dosage_ \
		--geneExp_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchUKBB/RNAseq_data/${t}/RNAseq_filt.txt \
		--ncores 32 \
		--outFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/200kb/noGWAS/ \
		--InfoFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/ \
		--functR ${git_fold}PriLer_functions.R \
		--part1Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/200kb/ \
		--part2Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/200kb/noGWAS/ \
		--part3Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/200kb/noGWAS/ \
		--priorDat_file ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/priorMatrix_ \
		--priorInf ${priorInd[@]}  

done
 




