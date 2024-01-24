#!/bin/bash

#SBATCH --job-name=ngs1cmc
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=4G

# Source: Application/SCZ_PGC2/training/CMC_release1/ElNet_withPrior_part1_200kb.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/PriLer_PROJECT_CMC
l=/scratch/tmp/dolgalev/castom-igex-revision/PriLer_PROJECT_CMC
g=~/tools/castom-igex/Software/model_training


mkdir -p "${l}/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/"

for i in $(seq 22); do
  ${g}/PriLer_part1_run.R  \
    --curChrom "chr${i}" \
    --covDat_file "${c}/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt" \
    --genoDat_file "${c}/INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/Genotype_dosage_caucasian_maf001_info06_" \
    --geneExp_file "${c}/INPUT_DATA_matchSCZ-PGC/CMC/RNAseq_data/EXCLUDE_ANCESTRY_SVA/RNAseq_filt.txt" \
    --ncores 12 \
    --outFold "${l}/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/" \
    --InfoFold "${c}/OUTPUT_SCZ-PGC_SCRIPTS_v2/" \
    --functR "${g}/PriLer_functions.R"
done