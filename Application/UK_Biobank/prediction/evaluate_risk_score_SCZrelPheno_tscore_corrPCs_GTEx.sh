#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/evaluate_risk_score_tscore_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/evaluate_risk_score_tscore_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=40G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/Tissue_noGWAS
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/
input_f=INPUT_DATA/Covariates/
fold_out=${fold}/update_corrPCs/

name_file=$(awk '{print $1}' INPUT_DATA/Covariates/name_pheno_clusterSCZ.txt)
name_file=(${name_file// / })
pheno_file=()

for i in ${name_file[@]}
do
	pheno_file+=(${input_f}phenotypeMatrix_${i}.txt)
done



${git_fold}evaluate_risk_score_run.R \
	--sampleAnn_file INPUT_DATA/Covariates/covariatesMatrix_red_latestW_202202.txt \
	--outFold ${fold_out}matchPGC_tscore_corr2Thr0.1_relatedPhenotypes_ \
	--riskScore_file ${fold_out}matchPGC_tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt \
	--names_pheno ${name_file[@]} \
	--pheno_file ${pheno_file[@]} \
	--phenoAnn_file /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/phenotypeDescription_rsSCZ.txt \
