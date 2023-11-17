#!/usr/bin/sh


######################################
### Compute prior (all cell types) ###
#####################################

Rscript Compute_priorMat_fin_run.R --chr $1 --inputDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/ --outputDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/  --VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchUKBB/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-UKBB_   

 
