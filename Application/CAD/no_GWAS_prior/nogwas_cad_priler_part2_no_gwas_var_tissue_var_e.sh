#!/bin/bash

#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=long
#SBATCH --time=7-00:00:00
#SBATCH --cpus-per-task=9
#SBATCH --mem-per-cpu=4G

# Source: Application/CAD/training/ElNet_withPrior_part2_200kb_tissue_CADgwas5e-2_*.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/PriLer_PROJECT_GTEx
l=/scratch/tmp/dolgalev/castom-igex-revision/PriLer_PROJECT_GTEx
g=~/tools/castom-igex/Software/model_training


t=$1
e=${*:2}


priorInd=$(awk '{print $1}' "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CAD_nogwas_withIndex.txt")

${g}/PriLer_part2_run.R \
  --covDat_file "${c}/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt" \
  --genoDat_file "${c}/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_dosage_" \
  --geneExp_file "${c}/INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/RNAseq_filt.txt" \
  --ncores 9 \
  --outFold "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/" \
  --InfoFold "${c}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/" \
  --functR "${g}/PriLer_functions.R" \
  --part1Res_fold "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/" \
  --priorDat_file "${c}/OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_" \
  --priorInf ${priorInd} \
  --E_set ${e}