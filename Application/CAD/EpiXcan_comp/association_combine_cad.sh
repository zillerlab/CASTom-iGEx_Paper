#!/bin/bash

#SBATCH --job-name=assccomb
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=30G

# Source: 
# Application/CAD/prediction/PriLer_phenoAssociation_GTEx_combine_CAD.sh
# Application/CAD/prediction/PriLer_phenoAssociation_GTEx_combine_wikiPath_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results/ukbb
g=~/tools/castom-igex


${g}/Software/model_prediction/pheno_association_combine_largeData_run.R \
  --names_file CAD \
  --tscoreFold "${l}/Association_tscore_res/" \
  --pathScoreFold_Reactome "${l}/Association_reactome_res/" \
	--pathScoreFold_GO "${l}/Association_GO_res/" \
  --outFold "${l}/" \
  --cov_corr T \
  --phenoAnn_file "${c}/Covariates/UKBB/phenotypeDescription_CAD.txt" \
  --reactome_file "${g}/refData/ReactomePathways.gmt" \
  --GOterms_file "${g}/refData/GOterm_geneAnnotation_allOntologies.RData"


${g}/Software/model_prediction/pheno_association_combine_largeData_customPath_run.R \
  --names_file CAD \
  --tscoreFold "${l}/Association_tscore_res/" \
  --pathScoreFold "${l}/Association_WikiPath2019Human_res/" \
  --outFold "${l}/" \
  --cov_corr T \
  --phenoAnn_file "${c}/Covariates/UKBB/phenotypeDescription_CAD.txt" \
  --pathwayCustom_file "${g}/refData/WikiPathways_2019_Human.RData" \
  --pathwayCustom_name WikiPath2019Human