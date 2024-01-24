#!/bin/bash

#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G

# Source: 
# Application/CAD/prediction/ElNet_withPrior_metaAnalysis_phenoAssociation_200kb.sh
# Application/CAD/prediction/PriLer_phenoAssociation_wikiPath_CardioGram_meta_GTEx.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/OUTPUT_CAD/predict_CAD
g=~/tools/castom-igex


t=$1

cohorts=(German1 German2 German3 German4 German5 CG LURIC MG WTCCC)


mkdir -p "${l}/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/Meta_Analysis_CAD/"

res_files=()
pheno_files=()

for cohort in "${cohorts[@]}"; do
  res_files+=("${l}/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/devgeno0.01_testdevgeno0/pval_CAD_pheno_covCorr.RData")
  pheno_files+=("${c}/Covariates/${cohort}/phenoMatrix.txt")
done

${g}/Software/model_prediction/pheno_association_metaAnalysis_run.R \
  --res_cohorts "${res_files[@]}" \
  --phenoDatFile_cohorts "${pheno_files[@]}" \
  --phenoName Dx \
  --outFold "${l}/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/Meta_Analysis_CAD/" \
  --GOterms_file "${g}/refData/GOterm_geneAnnotation_allOntologies.RData" \
  --reactome_file "${g}/refData/ReactomePathways.gmt" \
  --cov_corr T \
  --name_cohort "${cohorts[@]}"


res_files=()
pheno_files=()

for cohort in "${cohorts[@]}"; do
  res_files+=("${l}/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/${cohort}/devgeno0.01_testdevgeno0/pval_CAD_pheno_covCorr_customPath_WikiPath2019Human.RData")
  pheno_files+=("${c}/Covariates/${cohort}/phenoMatrix.txt")
done

# correct for covariates
${g}/Software/model_prediction/pheno_association_customPath_metaAnalysis_run.R \
  --res_cohorts "${res_files[@]}" \
  --phenoDatFile_cohorts "${pheno_files[@]}" \
  --phenoName Dx \
  --outFold "${l}/${t}/200kb/CAD_GWAS_bin5e-2_nogwas/Meta_Analysis_CAD/" \
  --pathwayStructure_file "${g}/refData/WikiPathways_2019_Human.RData" \
  --geneSetName WikiPath2019Human \
  --cov_corr T \
  --name_cohort "${cohorts[@]}"