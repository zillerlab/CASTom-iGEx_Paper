#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_prepare_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_prepare_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=60G
#SBATCH --cpus-per-task=1

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/
 
fold_train=OUTPUT_GTEx/train_GTEx/${t}/200kb/CAD_GWAS_bin5e-2/
fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/

${git_fold}pheno_association_prepare_largeData_run.R \
	--split_tot 100 \
	--geneAnn_file ${fold_train}resPrior_regEval_allchr.txt \
	--inputFold ${fold} \
	--outFold ${fold} \
	--GOterms_file ${ref_fold}GOterm_geneAnnotation_allOntologies.RData \
	--reactome_file ${ref_fold}ReactomePathways.gmt \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt
