#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/predExpr_downs_GTEx_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/predExpr_downs_GTEx_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=25G

module load R/3.5.3	

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
id_split=${SLURM_ARRAY_TASK_ID}

t=$1
perc=$2

#readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
#t=$(eval echo "\${tissues[${id_t}-1]}")

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
train_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/
out_fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/downsampling/perc${perc}/

mkdir -p ${out_fold}

# cov matrix splitted already created for UKBB only dataset, filter further when computing Tscore

${git_fold}PriLer_predictGeneExp_run.R \
	--genoDat_file INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/Genotype_dosage_split${id_split}_ \
	--covDat_file /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariates_split${id_split}_tmp.txt \
	--outFold ${out_fold}/split${id_split}_ \
	--outTrain_fold ${train_fold}/200kb/downsampling/perc${perc}/CAD_GWAS_bin5e-2/ \
	--InfoFold ${train_fold} 
