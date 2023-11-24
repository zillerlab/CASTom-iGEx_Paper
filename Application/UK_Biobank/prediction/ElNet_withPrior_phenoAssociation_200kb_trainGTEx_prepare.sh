#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_prepare_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_prepare_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=60G
#SBATCH --cpus-per-task=1

module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
if [ -z $1 ] 
then 
	split_tot=100
else
	split_tot=$1
fi


readarray -t tissues < OUTPUT_GTEx/Tissue_noGWAS
t=$(eval echo "\${tissues[${id_t}-1]}")
 
git_fold=/psycl/g/mpsziller/lucia/castom-igex/
git_fold_ref=/psycl/g/mpsziller/lucia/castom-igex/refData/

${git_fold}pheno_association_prepare_largeData_run.R \ 
	--split_tot ${split_tot} \
	--geneAnn_file OUTPUT_GTEx/train_GTEx/${t}/200kb/noGWAS/resPrior_regEval_allchr.txt \
	--inputFold OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/ \
	--outFold OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/ \
	--GOterms_file ${git_fold_ref}GOterm_geneAnnotation_allOntologies.RData \
	--reactome_file ${git_fold_ref}ReactomePathways.gmt \
	--sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix.txt 
