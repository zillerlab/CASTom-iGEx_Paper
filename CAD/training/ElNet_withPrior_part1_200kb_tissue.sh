#!/bin/bash

t=$1

mkdir -p /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb
git_fold=/mnt/lucia/castom-igex/Software/model_training/

for i in $(seq 22)
do
	echo 'chr' $i

	Rscript ${git_fold}PriLer_part1_run.R  --curChrom chr$i --covDat_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt --genoDat_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_dosage_ --geneExp_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/RNAseq_filt.txt --ncores 31 --outFold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/ --InfoFold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/ --functR ${git_fold}PriLer_functions.R 

done

