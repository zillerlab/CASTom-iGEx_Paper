#!/bin/bash

t=$1

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
cov_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}/
fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/

${git_fold}Tscore_PathScore_diff_run.R \
    --input_file ${fold}200kb/PGC_GWAS_bin1e-2/predict/predictedExpression.txt.gz \
    --reactome_file /psycl/g/mpsziller/lucia/castom-igex/refData/ReactomePathways.gmt \
    --GOterms_file /psycl/g/mpsziller/lucia/castom-igex/refData/GOterm_geneAnnotation_allOntologies.RData \
    --covDat_file ${cov_fold}covariates_EuropeanSamples.txt \
    --outFold ${fold}200kb/PGC_GWAS_bin1e-2/predict/ \
    --nFolds 40

