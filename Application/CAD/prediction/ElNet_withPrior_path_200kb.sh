#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pathDiff_%x_%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pathDiff_%x_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=40G

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
cohort=$1

id_t=${SLURM_ARRAY_TASK_ID}

readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/ 

${git_fold}Tscore_PathScore_diff_run.R \
	--covDat_file INPUT_DATA_GTEx/CAD/Covariates/${cohort}/covariateMatrix.txt \
	--input_file OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/predictedExpression.txt.gz \
	--outFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/devgeno0.01_testdevgeno0/ \
	--nFolds 40 \
	--GOterms_file ${ref_fold}GOterm_geneAnnotation_allOntologies.RData \
	--reactome_file ${ref_fold}ReactomePathways.gmt


