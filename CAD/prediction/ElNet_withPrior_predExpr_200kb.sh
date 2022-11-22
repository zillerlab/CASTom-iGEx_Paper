#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/predExpr_%x_%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/predExpr_%x_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=40G
#SBATCH --cpus-per-task=1

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
cohort=$1

id_t=${SLURM_ARRAY_TASK_ID}

readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
git_fold=/psycl/g/mpsziller/lucia/priler_project/Software/model_prediction/

Rscript ${git_fold}ElNet_withPrior_predictGeneExp_run.R --genoDat_file INPUT_DATA_GTEx/CAD/Genotyping_data/${cohort}/Genotype_dosage_ --covDat_file INPUT_DATA_GTEx/CAD/Covariates/${cohort}/covariateMatrix.txt --outFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/ --outTrain_fold OUTPUT_GTEx/train_GTEx/${t}/200kb/CAD_GWAS_bin5e-2/ --InfoFold OUTPUT_GTEx/train_GTEx/${t}/ 


