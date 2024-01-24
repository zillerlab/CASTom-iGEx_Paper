#!/bin/bash

#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G

# Source: 
# Application/CAD/prediction/ElNet_withPrior_phenoAssociation_200kb_CAD.sh
# Application/CAD/prediction/PriLer_phenoAssociation_wikiPath_CardioGram_GTEx.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision
g=~/tools/castom-igex


t=$1
cohort=$2


${g}/Software/model_prediction/pheno_association_smallData_run.R \
  --covDat_file "${c}/Covariates/${cohort}/covariateMatrix.txt" \
  --phenoDat_file "${c}/Covariates/${cohort}/phenoMatrix.txt" \
  --phenoAnn_file "${c}/Covariates/phenotypeDescription_SchunkertCohorts.csv" \
  --geneAnn_file "${l}/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/resPrior_regEval_allchr.txt" \
  --inputFold "${l}/OUTPUT_CAD/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/devgeno0.01_testdevgeno0/" \
  --outFold "${l}/OUTPUT_CAD/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/devgeno0.01_testdevgeno0/" \
  --GOterms_file "${g}/refData/GOterm_geneAnnotation_allOntologies.RData" \
  --reactome_file "${g}/refData/ReactomePathways.gmt" \
  --cov_corr T \
  --functR "${g}/Software/model_prediction/pheno_association_functions.R" \
  --sampleAnn_file "${c}/Covariates/${cohort}/covariateMatrix.txt" \
  --names_file CAD_pheno


${g}/Software/model_prediction/pheno_association_smallData_customPath_run.R \
  --covDat_file "${c}/Covariates/${cohort}/covariateMatrix.txt" \
  --phenoDat_file "${c}/Covariates/${cohort}/phenoMatrix.txt" \
  --geneAnn_file "${l}/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/resPrior_regEval_allchr.txt" \
  --inputFold "${l}/OUTPUT_CAD/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/devgeno0.01_testdevgeno0/" \
  --outFold "${l}/OUTPUT_CAD/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/devgeno0.01_testdevgeno0/" \
  --pathwayStructure_file "${g}/refData/WikiPathways_2019_Human.RData" \
  --cov_corr T \
  --functR "${g}/Software/model_prediction/pheno_association_functions.R" \
  --sampleAnn_file "${c}/Covariates/${cohort}/covariateMatrix.txt" \
  --names_file CAD_pheno \
  --phenoAnn_file "${c}/Covariates/phenotypeDescription_SchunkertCohorts.csv" \
  --geneSetName WikiPath2019Human