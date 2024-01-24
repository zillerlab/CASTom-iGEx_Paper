#!/bin/bash

#SBATCH --job-name=asscwiki
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G

# Source: Application/CAD/prediction/PriLer_phenoAssociation_GTEx_wikiPath_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results/ukbb
g=~/tools/castom-igex/Software/model_prediction


mkdir -p "${l}/Association_WikiPath2019Human_res/"


${g}/pheno_association_pathscore_largeData_run.R \
  --inputInfoFile "${l}/pathScore_WikiPath2019Human_info.RData" \
  --covDat_file "${c}/Covariates/UKBB/covariateMatrix_latestW_202304.txt" \
  --phenoDat_file "${c}/Covariates/UKBB/phenoMatrix_updateCADHARD.txt" \
  --names_file CAD \
  --inputFile "${l}/Pathway_WikiPath2019Human_scores_splitPath1.RData" \
  --outFile "${l}/Association_WikiPath2019Human_res/pval_pathScore_WikiPath2019Human_splitPath1_" \
  --cov_corr T \
  --sampleAnn_file "${c}/Covariates/UKBB/covariateMatrix_latestW_202304.txt" \
  --ncores 1 \
  --phenoAnn_file "${c}/Covariates/UKBB/phenotypeDescription_CAD.txt" \
  --functR "${g}/pheno_association_functions.R" \
  --path_type WikiPath2019Human