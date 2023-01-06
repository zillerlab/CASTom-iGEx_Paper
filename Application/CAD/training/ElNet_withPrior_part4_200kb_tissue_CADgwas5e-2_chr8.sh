#!/bin/bash

t=$1

priorInd=$(awk '{print $1}' /mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas_withIndex.txt)

#for i in $(seq 22)
#do
i=8
echo 'chr' $i

Rscript /mnt/lucia/eQTL_PROJECT_GTEx/RSCRIPTS/SCRIPTS_v2/ElNet_withPrior_part4_run.R  --curChrom chr${i} --covDat_file /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt --genoDat_file /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_dosage_ --geneExp_file /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/RNAseq_filt.txt --ncores 31 --outFold /mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --InfoFold /mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/ --functR /mnt/lucia/eQTL_PROJECT_GTEx/RSCRIPTS/SCRIPTS_v2/ElNet_withPrior_functions_run.R  --part1Res_fold /mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/ --part2Res_fold /mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --part3Res_fold /mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --priorDat_file /mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_ --priorInf ${priorInd[@]}  

#done
 




