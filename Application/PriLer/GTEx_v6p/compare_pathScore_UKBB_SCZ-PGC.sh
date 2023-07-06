#!/bin/bash

t=$1
path=$2
f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/Software/model_clustering/

fold1=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/$t/200kb/noGWAS/predict/
fold2=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/$t/200kb/PGC_GWAS_bin1e-2/predict/

${git_fold}compare_pathScore_matchedDataset_run.R \
    --pathScore_file ${fold1}Pathway_${path}_scores.txt ${fold2}Pathway_${path}_scores.txt \
    --tissue_name ${t} \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/compare_prediction_UKBB_SCZ-PGC/ \
    --type_path ${path}
