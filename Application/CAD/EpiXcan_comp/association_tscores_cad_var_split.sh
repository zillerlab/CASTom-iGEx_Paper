#!/bin/bash

#SBATCH --job-name=assctsco
#SBATCH --output=out/%x/%x_%A_%a.out
#SBATCH --error=err/%x/%x_%A_%a.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=20G

# Source: Application/CAD/prediction/PriLer_phenoAssociation_GTEx_tscore_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results/ukbb
g=~/tools/castom-igex/Software/model_prediction


mkdir -p "${l}/Association_tscore_res/"

${g}/pheno_association_tscore_largeData_run.R \
  --split_tot 100 \
  --inputInfoFile "${l}/tscore_info.RData" \
  --covDat_file "${c}/Covariates/UKBB/covariateMatrix_latestW_202304.txt" \
  --phenoDat_file "${c}/Covariates/UKBB/phenoMatrix_updateCADHARD.txt" \
  --names_file CAD \
  --inputFile "${l}/predictedTscores_splitGenes${SLURM_ARRAY_TASK_ID}.RData" \
  --outFile "${l}/Association_tscore_res/pval_tscore_splitGene${SLURM_ARRAY_TASK_ID}_" \
  --split_gene_id ${SLURM_ARRAY_TASK_ID} \
  --cov_corr T \
  --sampleAnn_file "${c}/Covariates/UKBB/covariateMatrix_latestW_202304.txt" \
  --ncores 2 \
  --phenoAnn_file "${c}/Covariates/UKBB/phenotypeDescription_CAD.txt" \
  --functR "${g}/pheno_association_functions.R" 