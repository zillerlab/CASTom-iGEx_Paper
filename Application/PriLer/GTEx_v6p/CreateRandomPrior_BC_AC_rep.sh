#!/usr/bin/sh


######################################
### Compute prior (all cell types) ###
#####################################

Rscript Compute_priorMat_random_AC_BC_withRep_run.R \
    --chr chr${1} \
    --EpiRandom_File /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/hg19_SNPs-Epi_randomSC_ \
    --Epi_File /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/hg19_SNPs-Epi_ \
    --GWAS_File /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/randomGWAS/randomGWAS_PVAL_PGC-CAD_ \
    --outputFile /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/priorMatrix_random_Ctrl_150_allPeaks_allRanger_heart_left_ventricle_GWAS_withRep_

 
