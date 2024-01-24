#!/bin/bash

#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=2G

# Source: Application/CAD/training/ElNet_withPrior_part1_200kb_tissue.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/PriLer_PROJECT_GTEx
l=/scratch/tmp/dolgalev/castom-igex-revision/PriLer_PROJECT_GTEx
g=~/tools/castom-igex/Software/model_training


t=$1


for i in $(seq 22); do
  ${g}/PriLer_part1_run.R \
    --curChrom "chr${i}" \
    --covDat_file "${c}/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt" \
    --genoDat_file "${c}/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_dosage_" \
    --geneExp_file "${c}/INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/RNAseq_filt.txt" \
    --ncores 12 \
    --outFold "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/" \
    --InfoFold "${c}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/" \
    --functR "${g}/PriLer_functions.R" 
done