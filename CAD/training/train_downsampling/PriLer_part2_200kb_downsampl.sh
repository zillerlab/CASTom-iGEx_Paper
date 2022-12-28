#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/err_out_fold/%x_200kb.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/err_out_fold/%x_200kb.err
#SBATCH --time=10-0

module load R/3.5.3

ncores=$1
t=$2
perc=$3
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_training/

if [[ ${perc} == 50 && ${t} == "Heart_Left_Ventricle" ]]
then
   E_set=(1 1.5 2 2.5 3 3.5 4)
else
   E_set=(3 3.5 4 4.5 5 5.5 6)
fi

cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/

priorInd=$(awk '{print $1}' OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas_withIndex.txt)
mkdir -p OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/CAD_GWAS_bin5e-2/

${git_fold}PriLer_part2_run.R \
	--covDat_file INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples_downsample${perc}.txt  \
	--genoDat_file INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_dosage_ \
	--geneExp_file INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/RNAseq_filt.txt \
	--InfoFold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/ \
	--part1Res_fold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/ \
	--priorDat_file OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_ \
	--priorInf ${priorInd[@]} \
        --ncores ${ncores} \
	--functR ${git_fold}PriLer_functions.R \
	--E_set ${E_set[@]} \
	--outFold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/CAD_GWAS_bin5e-2/
