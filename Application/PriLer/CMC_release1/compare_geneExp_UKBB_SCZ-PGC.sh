#!/bin/bash
#SBATCH --job-name=prior
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/compare_predExp_UKBB_SCZ.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/compare_predExp_UKBB_SCZ.err
#SBATCH --mem=30G
#SBATCH -c 1
#SBATCH -p hp


f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/Software/model_clustering/

fold1=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_UKBB_SCRIPTS_v2/predict_All/
fold2=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/predict_All/DLPC_CMC/

${git_fold}compare_geneExp_matchedDataset_run.R \
    --geneExpPred_file ${fold1}predictedExpression.txt.gz ${fold2}predictedExpression.txt.gz \
    --outFold /psycl/g/mpsziller/lucia/compare_prediction_UKBB_SCZ-PGC/ \
    --tissue_name DLPC_CMC

