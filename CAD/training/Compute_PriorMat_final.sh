#!/usr/bin/sh


######################################
### Compute prior (all cell types) ###
#####################################

Rscript /mnt/lucia/PriLer_PROJECT_GTEx/RSCRIPTS/Compute_priorMat_fin_run.R --chr $1 --inputDir /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/ --outputDir /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/  --VarInfo_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-CADall-UKBB_   

 
