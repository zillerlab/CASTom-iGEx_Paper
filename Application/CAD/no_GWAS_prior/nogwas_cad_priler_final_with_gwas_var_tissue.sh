#!/bin/bash

#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=12G

# Source: Application/CAD/training/ElNet_withPrior_finalOut_200kb_tissue_CADgwas5e-2.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/PriLer_PROJECT_GTEx
l=/scratch/tmp/dolgalev/castom-igex-revision/PriLer_PROJECT_GTEx
g=~/tools/castom-igex/Software/model_training


t=$1


priorInd=$(awk '{print $1}' "${c}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas_withIndex.txt")

${g}/PriLer_finalOutput_run.R \
  --covDat_file "${c}/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt" \
  --outFold "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/" \
  --InfoFold "${c}/OUTPUT_SCRIPTS_v2_CAD_UKBB/" \
  --functR "${g}/PriLer_functions.R" \
  --part1Res_fold "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/" \
  --part2Res_fold "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/" \
  --part3Res_fold "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/" \
  --part4Res_fold "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/" \
  --priorDat_file "${c}/OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_" \
  --priorInf ${priorInd}