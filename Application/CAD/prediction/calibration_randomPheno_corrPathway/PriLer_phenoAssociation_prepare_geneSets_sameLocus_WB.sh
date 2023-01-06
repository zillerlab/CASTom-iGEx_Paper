#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_prepare_geneSets_locus_WB.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_prepare_geneSets_locus_WB.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=60G

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
t=Whole_Blood

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
fold_train=OUTPUT_GTEx/train_GTEx/${t}/200kb/CAD_GWAS_bin5e-2/
fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/

Rscript ${git_fold}pheno_association_prepare_largeData_run.R \
	--split_tot 100 \
	--geneAnn_file ${fold_train}resPrior_regEval_allchr.txt \
	--inputFold ${fold} \
	--outFold ${fold} \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--pathwayCustom_file ${fold}/geneSets_sameLocus_sameSign.RData \
	--pathwayCustom_name geneSets_sameLocus \
	--skip_tscore_info T
