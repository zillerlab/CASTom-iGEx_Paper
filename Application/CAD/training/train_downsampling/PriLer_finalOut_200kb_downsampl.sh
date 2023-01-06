#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/err_out_fold/%x_200kb.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/err_out_fold/%x_200kb.err
#SBATCH --time=10-0

module load R/3.5.3

t=$1
perc=$2
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_training/

cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/

priorInd=$(awk '{print $1}' OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas_withIndex.txt)

${git_fold}PriLer_finalOutput_run.R \
	--covDat_file INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples_downsample${perc}.txt  \
	--InfoFold OUTPUT_SCRIPTS_v2_CAD_UKBB/ \
	--part1Res_fold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/ \
	--part2Res_fold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/CAD_GWAS_bin5e-2/ \
	--part3Res_fold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/CAD_GWAS_bin5e-2/ \
	--part4Res_fold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/CAD_GWAS_bin5e-2/ \
	--priorDat_file OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_ \
	--priorInf ${priorInd[@]} \
	--functR ${git_fold}PriLer_functions.R \
	--outFold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/CAD_GWAS_bin5e-2/
