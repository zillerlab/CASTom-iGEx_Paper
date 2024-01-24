#!/bin/bash

#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G

# Source: 
# Application/CAD/prediction/ElNet_withPrior_path_200kb.sh; 
# Application/CAD/prediction/PathScore_wikiPath_CardioGram_GTEx.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/OUTPUT_CAD/predict_CAD
g=~/tools/castom-igex


t=$1
cohort=$2


mkdir -p "${l}/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/devgeno0.01_testdevgeno0/"

${g}/Software/model_prediction/Tscore_PathScore_diff_run.R \
  --covDat_file "${c}/Covariates/${cohort}/covariateMatrix.txt" \
  --input_file "${l}/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/predictedExpression.txt.gz" \
  --outFold "${l}/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/devgeno0.01_testdevgeno0/" \
  --nFolds 40 \
  --GOterms_file "${g}/refData/GOterm_geneAnnotation_allOntologies.RData" \
  --reactome_file "${g}/refData/ReactomePathways.gmt"


${g}/Software/model_prediction/pathScore_customGeneList_run.R \
  --sampleAnn_file "${c}/Covariates/${cohort}/covariateMatrix.txt" \
  --pathwayStruct_file "${g}/refData/WikiPathways_2019_Human.RData" \
  --tscore_file "${l}/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/devgeno0.01_testdevgeno0/predictedTscores.txt" \
  --outFold "${l}/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/devgeno0.01_testdevgeno0/" \
  --geneSetName WikiPath2019Human