#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/Tscore_GTEx_%x_splitGenes%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/Tscore_GTEx_%x_splitGenes%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=3000MB
#SBATCH --cpus-per-task=39

module load R

id_t=$1

readarray -t tissues < /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/Tissue_noGWAS
t=$(eval echo "\${tissues[${id_t}-1]}")

inputfile=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/
covfile=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/

inputfile_list=()
for i in $(seq 100)
do
	inputfile_list+=(${inputfile}split${i}_predictedExpression_filt.txt)
done

cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

${git_fold}Tscore_splitGenes_run.R \
	--input_file ${inputfile_list[@]} \
	--nFolds 10 \
	--perc_comp 0.8 \
	--ncores 39 \
	--covDat_file INPUT_DATA/Covariates/covariatesMatrix.txt \
	--outFold OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/ \
	--split_gene_id ${SLURM_ARRAY_TASK_ID} \
	--split_tot 100

