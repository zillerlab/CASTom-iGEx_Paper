#!/bin/bash

#SBATCH --job-name=ngsfncmc
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x-%j.err

#SBATCH --partition=normal
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=12G

# Source: Application/SCZ_PGC2/training/CMC_release1/ElNet_withPrior_finalOut_200kb.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/PriLer_PROJECT_CMC
l=/scratch/tmp/dolgalev/castom-igex-revision/PriLer_PROJECT_CMC
g=~/tools/castom-igex/Software/model_training


${g}/PriLer_finalOutput_run.R \
  --covDat_file "${c}/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt" \
  --outFold "${l}/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/PGC_GWAS_bin1e-2_nogwas/" \
  --InfoFold "${c}/OUTPUT_SCZ-PGC_SCRIPTS_v2/" \
  --functR "${g}/PriLer_functions.R" \
  --part1Res_fold "${l}/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/" \
  --part2Res_fold "${l}/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/PGC_GWAS_bin1e-2_nogwas/" \
  --part3Res_fold "${l}/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/PGC_GWAS_bin1e-2_nogwas/" \
  --part4Res_fold "${l}/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/PGC_GWAS_bin1e-2_nogwas/" \
  --priorDat_file "${c}/OUTPUT_SCZ-PGC_SCRIPTS_v2/priorMatrix_" \
  --priorInf 2 3 4 5 6 7 8 9 10 11 12 13 14 15