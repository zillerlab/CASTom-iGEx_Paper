#!/bin/bash
#SBATCH --job-name=pheno
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/phenoAssoc_All_SCZ-PGC.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/phenoAssoc_All_SCZ-PGC.err
#SBATCH --mem=30G
#SBATCH -c 1
#SBATCH -p hp


git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
cov_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/
fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/

${git_fold}pheno_association_smallData_run.R \
    --sampleAnn_file ${cov_fold}covariateMatrix.txt \
    --reactome_file /psycl/g/mpsziller/lucia/castom-igex/refData/ReactomePathways.gmt \
    --GOterms_file /psycl/g/mpsziller/lucia/castom-igex/refData/GOterm_geneAnnotation_allOntologies.RData \
    --inputFold ${fold}predict_All/DLPC_CMC/devgeno0.01_testdevgeno0/ \
    --covDat_file ${cov_fold}covariateMatrix.txt \
    --names_file Dx \
    --cov_corr T \
    --phenoDat_file ${cov_fold}phenoDat_allDx.txt \
    --phenoAnn_file ${cov_fold}phenotypeDescription_CMC_allDx.csv \
    --geneAnn_file ${fold}train_All/200kb/resPrior_regEval_allchr.txt \
    --functR ${git_fold}pheno_association_functions.R \
    --outFold ${fold}predict_All/DLPC_CMC/devgeno0.01_testdevgeno0/


