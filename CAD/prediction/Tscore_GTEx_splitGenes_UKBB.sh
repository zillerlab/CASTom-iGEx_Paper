#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/Tscore_UKBB_%x_splitGenes%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/Tscore_UKBB_%x_splitGenes%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=3000MB
#SBATCH --cpus-per-task=30

module load R/3.5.3

id_t=$1

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")


inputfile=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/

inputfile_list=()
for i in $(seq 100)
do
	inputfile_list+=(${inputfile}split${i}_predictedExpression_filt.txt)
done

${git_fold}/Tscore_splitGenes_run.R \
	--input_file ${inputfile_list[@]} \
	--nFolds 10 \
	--perc_comp 0.7 \
	--ncores 30 \
	--covDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--outFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/ \
	--split_gene_id ${SLURM_ARRAY_TASK_ID} \
	--split_tot 100


