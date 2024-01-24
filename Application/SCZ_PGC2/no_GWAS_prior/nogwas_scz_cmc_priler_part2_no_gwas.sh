#!/bin/bash

#SBATCH --job-name=ngs2ncmc
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=long
#SBATCH --time=7-00:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=10G

# Source: Application/SCZ_PGC2/training/CMC_release1/ElNet_withPrior_part2_200kb.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/PriLer_PROJECT_CMC
l=/scratch/tmp/dolgalev/castom-igex-revision/PriLer_PROJECT_CMC
g=~/tools/castom-igex/Software/model_training


mkdir -p "${l}/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/PGC_GWAS_bin1e-2_nogwas"

# Remove '18' (PGC_GWAS_bin prior) from priorInf
${g}/PriLer_part2_run.R  \
  --covDat_file "${c}/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt" \
  --genoDat_file "${c}/INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/Genotype_dosage_caucasian_maf001_info06_" \
  --geneExp_file "${c}/INPUT_DATA_matchSCZ-PGC/CMC/RNAseq_data/EXCLUDE_ANCESTRY_SVA/RNAseq_filt.txt" \
  --ncores 10 \
  --outFold "${l}/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/PGC_GWAS_bin1e-2_nogwas/" \
  --InfoFold "${c}/OUTPUT_SCZ-PGC_SCRIPTS_v2/" \
  --functR "${g}/PriLer_functions.R" \
  --part1Res_fold "${c}/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/" \
  --priorDat_file "${c}/OUTPUT_SCZ-PGC_SCRIPTS_v2/priorMatrix_" \
  --priorInf 2 3 4 5 6 7 8 9 10 11 12 13 14 15 \
  --E_set 0.2 0.3 0.4 0.5 0.75 1 1.5 2 2.5 3