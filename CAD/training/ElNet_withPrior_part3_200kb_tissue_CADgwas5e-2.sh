#!/bin/bash

t=$1

priorInd=$(awk '{print $1}' /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas_withIndex.txt)
git_fold=/mnt/lucia/castom-igex/Software/model_training/

Rscript ${git_fold}PriLer_part3_run.R  --covDat_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt --genoDat_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_dosage_ --geneExp_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/RNAseq_filt.txt  --ncores 31 --outFold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --InfoFold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/ --functR ${git_fold}PriLer_functions.R --part2Res_fold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --priorDat_file /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_ --priorInf ${priorInd[@]} 


