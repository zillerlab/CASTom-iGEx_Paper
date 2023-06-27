#!/usr/bin/sh


######################################
### Compute prior (all cell types) ###
#####################################

Rscript /mnt/lucia/eQTL_PROJECT_GTEx/RSCRIPTS/Compute_priorMat_fin_run.R --chr $1 --inputDir /mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT/ --outputDir /mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/  --VarInfo_file /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_   

 
