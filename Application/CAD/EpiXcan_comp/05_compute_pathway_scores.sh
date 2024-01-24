#!/bin/bash

#SBATCH --job-name=epipscor
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=12G

# Source: Application/CAD/prediction/PathScore_GTEx.sh; Application/CAD/prediction/PathScore_wikiPath_GTEx.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan
g=~/tools/castom-igex


${g}/Software/model_prediction/PathwayScores_splitGenes_run.R \
  --ncores 10 \
  --split_tot 100 \
  --input_file "${l}/results/tscores/predictedTscores_splitGenes"  \
  --covDat_file "${c}/Covariates/UKBB/covariateMatrix_latestW_202304.txt" \
  --outFold "${l}/results/pscores/" \
  --reactome_file "${g}/refData/ReactomePathways.gmt" \
  --GOterms_file "${g}/refData/GOterm_geneAnnotation_allOntologies.RData"


${g}/Software/model_prediction/PathwayScores_splitGenes_customGeneList_run.R \
  --ncores 10 \
  --split_tot 100 \
  --input_file "${l}/results/tscores/predictedTscores_splitGenes" \
  --covDat_file "${c}/Covariates/UKBB/covariateMatrix_latestW_202304.txt" \
  --outFold "${l}/results/pscores/" \
  --pathwayStruct_file "${g}/refData/WikiPathways_2019_Human.RData" \
  --geneSetName WikiPath2019Human