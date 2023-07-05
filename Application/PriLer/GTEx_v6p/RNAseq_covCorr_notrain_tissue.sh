#!/bin/bash

t=$1


outFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/${t}/no_train/

Rscript RNAseq_covCorrected_trainOpt_run.R  \
--covFile /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt \
--outFold ${outFold} \
--exprDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/
