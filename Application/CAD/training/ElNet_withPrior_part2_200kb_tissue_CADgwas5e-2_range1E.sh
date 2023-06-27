#!/bin/bash

t=$1
git_fold=${f}castom-igex/Software/model_training/
f=/psycl/g/mpsziller/lucia/
priorInd=$(awk '{print $1}' ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas_withIndex.txt)

${git_fold}PriLer_part2_run.R  --covDat_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt --genoDat_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_dosage_ --geneExp_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/RNAseq_filt.txt --ncores 6 --outFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ --InfoFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/ --functR ${git_fold}PriLer_functions.R --part1Res_fold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/ --priorDat_file ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_ --priorInf ${priorInd[@]} --E_set 0.5 0.75 1 1.25 1.5 2


