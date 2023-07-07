#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/RNAseq_covCorr_%x_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/RNAseq_covCorr_%x_%j.err


Rscript RNAseq_covCorrected_trainOpt_run.R \
    --exprDir /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/RNAseq_data/EXCLUDE_ANCESTRY_SVA/ \
    --covFile /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/no_train/
