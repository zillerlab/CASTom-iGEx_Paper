#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/err_out_fold/%x_200kb.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/err_out_fold/%x_200kb.err
#SBATCH --time=10-0

module load R/3.5.3

ncores=$1
t=$2
perc=$3
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_training/

cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/

priorInd=$(awk '{print $1}' OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas_withIndex.txt)

${git_fold}PriLer_part3_run.R \
	--covDat_file INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples_downsample${perc}.txt  \
	--genoDat_file INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_dosage_ \
	--geneExp_file INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/RNAseq_filt.txt \
	--InfoFold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/ \
	--part2Res_fold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/CAD_GWAS_bin5e-2/ \
	--priorDat_file OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_ \
	--priorInf ${priorInd[@]} \
        --ncores ${ncores} \
	--functR ${git_fold}PriLer_functions.R \
	--outFold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/CAD_GWAS_bin5e-2/
