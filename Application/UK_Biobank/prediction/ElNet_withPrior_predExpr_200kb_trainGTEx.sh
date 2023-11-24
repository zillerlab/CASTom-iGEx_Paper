#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/predExpr_GTEx_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/predExpr_GTEx_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G

module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/
id_split=${SLURM_ARRAY_TASK_ID}

id_t=$1

readarray -t tissues < OUTPUT_GTEx/Tissue_noGWAS
t=$(eval echo "\${tissues[${id_t}-1]}")

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

${git_fold}PriLer_predictGeneExp_run.R \
    --genoDat_file INPUT_DATA_GTEx/UKBB/Genotyping_data/Genotype_dosage_split${id_split}_ \
    --covDat_file INPUT_DATA/Covariates/covariates_split${id_split}_tmp.txt \
    --outFold OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/split${id_split}_ \
    --outTrain_fold OUTPUT_GTEx/train_GTEx/${t}/200kb/noGWAS/ \
    --InfoFold OUTPUT_GTEx/train_GTEx/${t}/ 


