#!/bin/bash
#SBATCH --job-name=prior
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/predictAll_SCZ-PGC.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/predictAll_SCZ-PGC.err
#SBATCH --mem=30G
#SBATCH -c 1
#SBATCH -p hp


git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
cov_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/
geno_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/
fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/

${git_fold}PriLer_predictGeneExp_run.R \
    --genoDat_file ${geno_fold}Genotype_dosage_caucasian_maf001_info06_ \
    --covDat_file ${cov_fold}covariateMatrix.txt \
    --outFold ${fold}predict_All/ \
    --outTrain_fold ${fold}train_All/200kb/ \
    --InfoFold ${fold}


