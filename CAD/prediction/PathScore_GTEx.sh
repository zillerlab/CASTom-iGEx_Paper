#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/PathScore_GTEx_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/PathScore_GTEx_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=35G
#SBATCH --cpus-per-task=10

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/
id_t=$1

readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")


inputfold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
covfold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/

Rscript  ${git_fold}PathwayScores_splitGenes_run.R \
	--ncores 10 \
	--split_tot 100 \
	--input_file ${inputfold}predictedTscores_splitGenes  \
	--covDat_file ${covfold}covariateMatrix_latestW.txt \
	--outFold ${inputfold} \
	--reactome_file ${ref_fold}ReactomePathways.gmt \
	--GOterms_file ${ref_fold}GOterm_geneAnnotation_allOntologies.RData


