#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/PathScore_GTEx_wiki_downs_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/PathScore_GTEx_wiki_downs_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=35G
#SBATCH --cpus-per-task=5

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/

t=$1
perc=$2

inputFold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/downsampling/perc${perc}/devgeno0.01_testdevgeno0/
covFold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/

Rscript ${git_fold}PathwayScores_splitGenes_customGeneList_run.R \
	--ncores 10 \
	--split_tot 100 \
	--input_file ${inputFold}predictedTscores_splitGenes \
	--covDat_file ${covFold}covariateMatrix_latestW.txt  \
	--outFold ${inputFold} \
	--pathwayStruct_file ${ref_fold}WikiPathways_2019_Human.RData \
	--geneSetName WikiPath2019Human


