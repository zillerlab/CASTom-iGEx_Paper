#!/bin/bash

#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=2G

# Source: Application/PriLer/GTEx_v6p/ElNet_withPrior_part4_200kb_tissue_PGCgwas1e-2.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/PriLer_PROJECT_GTEx
l=/scratch/tmp/dolgalev/castom-igex-revision/PriLer_PROJECT_GTEx
g=~/tools/castom-igex/Software/model_training


t=Brain_Cortex
p=$1


priorInd=$(awk '{print $1}' "${l}/OUTPUT_SCRIPTS_v2/${t}/priorName_PGC_BC_gwas_${p}_withIndex.txt")

for i in $(seq 22); do
  ${g}/PriLer_part4_run.R \
    --curChrom "chr${i}" \
    --covDat_file "${c}/INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples.txt" \
    --genoDat_file "${c}/INPUT_DATA/Genotype_data/Genotype_dosage_" \
    --geneExp_file "${c}/INPUT_DATA/RNAseq_data/${t}/RNAseq_filt.txt" \
    --ncores 16 \
    --outFold "${l}/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin_${p}/" \
    --InfoFold "${c}/OUTPUT_SCRIPTS_v2/${t}/" \
    --functR "${g}/PriLer_functions.R" \
    --part1Res_fold "${c}/OUTPUT_SCRIPTS_v2/${t}/200kb/" \
    --part2Res_fold "${l}/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin_${p}/" \
    --part3Res_fold "${l}/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin_${p}/" \
    --priorDat_file "${l}/OUTPUT_SCRIPTS_v2/priorMatrix_" \
    --priorInf ${priorInd}  
done