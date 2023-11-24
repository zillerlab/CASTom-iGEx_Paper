#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/predExpr_CMC_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/predExpr_CMC_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G

module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/
id_split=${SLURM_ARRAY_TASK_ID}


git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

${git_fold}PriLer_predictGeneExp_run.R \
    --genoDat_file INPUT_DATA_CMC/UKBB/Genotyping_data/Genotype_dosage_split${id_split}_ \
    --covDat_file INPUT_DATA/Covariates/covariates_split${id_split}_tmp.txt \
    --outFold OUTPUT_CMC/predict_UKBB/200kb/split${id_split}_ \
    --outTrain_fold OUTPUT_CMC/train_CMC/${t}/200kb/
    --InfoFold OUTPUT_CMC/train_CMC/ 


