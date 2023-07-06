#!/bin/bash

t=$1
f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/Software/model_clustering/

fold1=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/$t/200kb/noGWAS/predict/
fold2=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/$t/200kb/PGC_GWAS_bin1e-2/predict/

${git_fold}compare_geneExp_matchedDataset_run.R \
    --geneExpPred_file ${fold1}predictedExpression.txt.gz ${fold2}predictedExpression.txt.gz \
    --tissue_name ${t} \
    --outFold /psycl/g/mpsziller/lucia/compare_prediction_UKBB_SCZ-PGC/
