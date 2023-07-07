#!/bin/bash
#SBATCH --job-name=prior
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/compare_pathScore_UKBB_SCZ.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/compare_pathScore_UKBB_SCZ.err
#SBATCH --mem=30G
#SBATCH -c 1
#SBATCH -p hp


f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/Software/model_clustering/

fold1=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_UKBB_SCRIPTS_v2/predict_All/devgeno0.01_testdevgeno0/
fold2=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/predict_All/DLPC_CMC/devgeno0.01_testdevgeno0/

${git_fold}compare_pathScore_matchedDataset_run.R \
    --pathScore_file ${fold1}Pathway_Reactome_scores.txt ${fold2}Pathway_Reactome_scores.txt \
    --outFold /psycl/g/mpsziller/lucia/compare_prediction_UKBB_SCZ-PGC/ \
    --type_path Reactome \
    --tissue_name DLPC_CMC

${git_fold}compare_pathScore_matchedDataset_run.R \
    --pathScore_file ${fold1}Pathway_GO_scores.txt ${fold2}Pathway_GO_scores.txt \
    --outFold /psycl/g/mpsziller/lucia/compare_prediction_UKBB_SCZ-PGC/ \
    --type_path GO \
    --tissue_name DLPC_CMC

