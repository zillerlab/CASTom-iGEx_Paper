#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_prepare_customPath_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_prepare_customPath_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=70G
#SBATCH --cpus-per-task=1

module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

#id_t=${SLURM_ARRAY_TASK_ID}

#readarray -t tissues < OUTPUT_GTEx/Tissue_noGWAS
#t=$(eval echo "\${tissues[${id_t}-1]}")
git_fold=/psycl/g/mpsziller/lucia/castom-igex/
git_fold_ref=/psycl/g/mpsziller/lucia/castom-igex/refData/

${git_fold}pheno_association_prepare_largeData_run.R \
    --geneAnn_file OUTPUT_CMC/train_CMC/200kb/resPrior_regEval_allchr.txt \
    --inputFold OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/ \
    --outFold OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/ \
    --sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix.txt \
    --geneSetName CMC_GeneSets \
    --pathwayStruct_file ${git_fold_ref}CMC_GeneSets_Hypothesis-driven-for-Enrichement.RData
