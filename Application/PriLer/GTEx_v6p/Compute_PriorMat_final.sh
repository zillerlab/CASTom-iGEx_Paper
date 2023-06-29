#!/usr/bin/sh


######################################
### Compute prior (all cell types) ###
#####################################

Rscript Compute_priorMat_fin_run.R \
    --chr $1 \
    --inputDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT/ \
    --outputDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/ \
    --VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_   

 
