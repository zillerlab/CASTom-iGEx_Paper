#!/bin/bash

#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=40G

# Source: Application/CAD/prediction/ElNet_withPrior_predExpr_200kb.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx
l=/scratch/tmp/dolgalev/castom-igex-revision
g=~/tools/castom-igex/Software/model_prediction


t=$1
cohort=$2


mkdir -p "${l}/OUTPUT_CAD/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}"

${g}/PriLer_predictGeneExp_run.R \
  --genoDat_file "${c}/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/${cohort}/Genotype_dosage_" \
  --covDat_file "${c}/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/${cohort}/covariateMatrix.txt" \
  --outFold "${l}/OUTPUT_CAD/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${cohort}/" \
  --outTrain_fold "${l}/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/" \
  --InfoFold "${c}/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/"