#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/combinePredExpr_GTEx_filtGenes_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/combinePredExpr_GTEx_filtGenes_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=40G

id_t=$1

readarray -t tissues < /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

inputFold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/ 
outFold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/

bash ${git_fold}Combine_filteredGeneExpr.sh ${inputFold} ${outFold} 100
