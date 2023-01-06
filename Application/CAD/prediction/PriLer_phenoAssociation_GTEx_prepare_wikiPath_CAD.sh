#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_prepare_wiki_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_prepare_wiki_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=80G

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
fold_train=OUTPUT_GTEx/train_GTEx/${t}/200kb/CAD_GWAS_bin5e-2/
fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/

echo ${fold}

Rscript ${git_fold}pheno_association_prepare_largeData_run.R \
	--split_tot 100 \
	--geneAnn_file ${fold_train}resPrior_regEval_allchr.txt \
	--inputFold ${fold} \
	--outFold ${fold} \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--pathwayCustom_file ${ref_fold}/WikiPathways_2019_Human.RData \
	--pathwayCustom_name WikiPath2019Human \
	--skip_tscore_info T
