#!/usr/bin/sh


######################################
### Compute prior (all cell types) ###
#####################################
f=/psycl/g/mpsziller/lucia/

Rscript Compute_priorMat_fin_run.R \
    --chr $1 \
    --inputDir ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/ \
    --outputDir ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/  \
    --VarInfo_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-CADall-UKBB_   

 
