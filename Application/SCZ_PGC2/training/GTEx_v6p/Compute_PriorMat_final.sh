#!/usr/bin/sh


######################################
### Compute prior (all cell types) ###
#####################################

Rscript ./Compute_priorMat_fin_run.R \
    --chr $1 \
    --inputDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/ \
    --outputDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/ \
    --VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/Genotype_data/Genotype_VariantsInfo_maf001_info06_GTEx-PGCgwas-SCZ-PGCall_   

 
