#!/bin/bash

#SBATCH --job-name=asscprep
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=12G

# Source: 
# Application/CAD/prediction/PriLer_phenoAssociation_GTEx_prepare_CAD.sh 
# Application/CAD/prediction/PriLer_phenoAssociation_GTEx_prepare_wikiPath_CAD.sh


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD
l=/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results
g=~/tools/castom-igex


mkdir "${l}/ukbb/"
mv ${l}/tscores/* "${l}/ukbb/"
mv ${l}/pscores/* "${l}/ukbb/"


${g}/Software/model_prediction/pheno_association_prepare_largeData_run.R \
  --split_tot 100 \
  --geneAnn_file "${l}/predexp/split1_predicted_expression_fmt.txt.gz" \
  --inputFold "${l}/ukbb/" \
  --outFold "${l}/ukbb/" \
  --GOterms_file "${g}/refData/GOterm_geneAnnotation_allOntologies.RData" \
  --reactome_file "${g}/refData/ReactomePathways.gmt" \
  --sampleAnn_file "${c}/Covariates/UKBB/covariateMatrix_latestW_202304.txt"


${g}/Software/model_prediction/pheno_association_prepare_largeData_run.R \
	--split_tot 100 \
	--geneAnn_file "${l}/predexp/split1_predicted_expression_fmt.txt.gz" \
	--inputFold "${l}/ukbb/" \
  --outFold "${l}/ukbb/" \
	--sampleAnn_file "${c}/Covariates/UKBB/covariateMatrix_latestW_202304.txt" \
	--pathwayCustom_file "${g}/refData/WikiPathways_2019_Human.RData" \
	--pathwayCustom_name WikiPath2019Human \
	--skip_tscore_info T