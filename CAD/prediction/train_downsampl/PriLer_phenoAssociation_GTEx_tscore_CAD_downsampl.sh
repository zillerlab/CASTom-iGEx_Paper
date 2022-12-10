#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_tscore_downs_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_tscore_downs_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=2

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

t=$1
perc=$2
fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/downsampling/perc${perc}/devgeno0.01_testdevgeno0/
mkdir -p ${fold}/Association_tscore_res/

${git_fold}pheno_association_tscore_largeData_run.R \
	--split_tot 100 \
	--inputInfoFile ${fold}tscore_info.RData \
	--covDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--phenoDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenoMatrix_updateCADHARD.txt \
	--names_file CAD  \
	--inputFile ${fold}predictedTscores_splitGenes${SLURM_ARRAY_TASK_ID}.RData \
	--outFile ${fold}Association_tscore_res/pval_tscore_splitGene${SLURM_ARRAY_TASK_ID}_ \
	--split_gene_id ${SLURM_ARRAY_TASK_ID} \
	--cov_corr T \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--ncores 4 \
	--phenoAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_CAD.txt \
	--functR ${git_fold}pheno_association_functions.R 
