#!/bin/bash
#SBATCH --job-name=path
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/pathDiff_All_UKBB.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/pathDiff_All_UKBB.err
#SBATCH --mem=30G
#SBATCH -c 1
#SBATCH -p hp


git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
cov_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/
fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_UKBB_SCRIPTS_v2/

mkdir -p ${fold}predict_All/devgeno0.01_testdevgeno0/

${git_fold}Tscore_PathScore_diff_run.R \
    --input_file ${fold}predict_All/predictedExpression.txt.gz \
    --reactome_file /psycl/g/mpsziller/lucia/castom-igex/refData/ReactomePathways.gmt \
    --GOterms_file /psycl/g/mpsziller/lucia/castom-igex/refData/GOterm_geneAnnotation_allOntologies.RData \
    --covDat_file ${cov_fold}covariateMatrix.txt \
    --outFold ${fold}predict_All/devgeno0.01_testdevgeno0/ \
    --nFolds 40
