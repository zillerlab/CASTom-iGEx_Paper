#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/combinePredExpr_downs_GTEx_filtGenes_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/combinePredExpr_downs_GTEx_filtGenes_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=40G

t=$1
perc=$2

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/CAD_GWAS_bin5e-2/ 
outFold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/downsampling/perc${perc}/

bash ${git_fold}Combine_filteredGeneExpr.sh ${inputFold} ${outFold} 100

