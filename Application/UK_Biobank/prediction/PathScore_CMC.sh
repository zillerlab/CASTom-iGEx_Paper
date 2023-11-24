#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/PathScore_CMC_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/PathScore_CMC_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=40G
#SBATCH --cpus-per-task=10

module load R

inputfold=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/
covfold=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/

cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
git_fold_ref=/psycl/g/mpsziller/lucia/castom-igex/refData/

${git_fold}PathwayScores_splitGenes_run.R \
    --ncores 10 \
    --input_file ${inputfold}predictedTscores_splitGenes \
    --covDat_file ${covfold}covariatesMatrix.txt \
    --outFold ${inputfold} \
    --split_tot 100 \
    --reactome_file ${git_fold_ref}ReactomePathways.gmt \
    --GOterms_file ${git_fold_ref}GOterm_geneAnnotation_allOntologies.RData


