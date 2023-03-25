#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/path_wiki_Indian_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/path_wiki_Indian_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}

readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
path_file=/psycl/g/mpsziller/lucia/castom-igex/refData/WikiPathways_2019_Human.RData

${git_fold}pathScore_customGeneList_run.R \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB_other_ancestry/covariateMatrix_latestW_202202_Indian.txt \
	--pathwayStruct_file ${path_file} \
	--tscore_file OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB_other_ancestry/devgeno0.01_testdevgeno0/predictedTscores.txt \
	--outFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB_other_ancestry/devgeno0.01_testdevgeno0/ \
	--geneSetName WikiPath2019Human

