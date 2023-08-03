#!/bin/bash
#SBATCH --job-name=path
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/pathDiff_All_SCZ-PGC.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/pathDiff_All_SCZ-PGC.err
#SBATCH --mem=30G
#SBATCH -c 1
#SBATCH -p hp


git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/ 
cov_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/
fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/

${git_fold}Tscore_PathScore_diff_run.R \
    --input_file ${fold}predict_All/DLPC_CMC/predictedExpression.txt.gz \
    --reactome_file ${ref_fold}ReactomePathways.gmt \
    --GOterms_file ${ref_fold}GOterm_geneAnnotation_allOntologies.RData \
    --covDat_file ${cov_fold}covariateMatrix.txt \
    --outFold ${fold}predict_All/DLPC_CMC/devgeno0.01_testdevgeno0/ \
    --nFolds 40
