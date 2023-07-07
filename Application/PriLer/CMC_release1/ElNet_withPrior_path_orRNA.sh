#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_orRNA_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_orRNA_%j.err


type_name=$1
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/ 

${git_fold}Tscore_PathScore_diff_run.R \ 
    --originalRNA T \
    --input_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/train_${type_name}/RNAseq_filt_covCorrected.txt \
    --GOterms_file ${ref_fold}GOterm_geneAnnotation_allOntologies.RData \
    --reactome_file ${ref_fold}ReactomePathways.gmt \
    --nFolds 40 \
    --covDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/pathwayAnalysis_OriginalRNA/train_${type_name}/ 

 

