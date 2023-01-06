#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/Tscore_UKBB_downs_%x_splitGenes%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/Tscore_UKBB_downs_%x_splitGenes%a.err
#SBATCH --time=10-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=8000MB
#SBATCH --cpus-per-task=10

module load R/3.5.3

t=$1
perc=$2

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

inputFold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/downsampling/perc${perc}/devgeno0.01_testdevgeno0/

inputfile_list=()
for i in $(seq 100)
do
	inputfile_list+=(${inputFold}split${i}_predictedExpression_filt.txt)
done

${git_fold}/Tscore_splitGenes_run.R \
	--input_file ${inputfile_list[@]} \
	--nFolds 10 \
	--perc_comp 0.7 \
	--ncores 20 \
	--covDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--outFold ${inputFold} \
	--split_gene_id ${SLURM_ARRAY_TASK_ID} \
	--split_tot 100


