#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/predExpr_Indian_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/predExpr_Indian_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=40G
#SBATCH --cpus-per-task=1

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}

readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

mkdir -p OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB_other_ancestry/

${git_fold}PriLer_predictGeneExp_run.R \
	--genoDat_file INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB_other_ancestry/Genotype_dosage_ \
	--covDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB_other_ancestry/covariateMatrix_latestW_202202_Indian.txt \
	--outFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB_other_ancestry/ \
	--outTrain_fold OUTPUT_GTEx/train_GTEx/${t}/200kb/CAD_GWAS_bin5e-2/ \
	--InfoFold OUTPUT_GTEx/train_GTEx/${t}/ 


