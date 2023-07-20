#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/eval_risk_score_CAD_tscore_corrPCs_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/eval_risk_score_CAD_tscore_corrPCs_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G


R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
fold_cl=${fold}/CAD_HARD_clustering/update_corrPCs/
input_f=INPUT_DATA_GTEx/CAD/Covariates/UKBB/
input_f_ukbb=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/

name_file=$(awk '{print $1}' INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/name_pheno_risk_score_eval.txt)
name_file=(${name_file// / })
pheno_file=()
for i in ${name_file[@]}
do
	if [[ "${i}" == "Blood_count_ratio" ]]
	then
		pheno_file+=(${input_f_ukbb}phenotypeMatrix_${i}.txt)
	else
		pheno_file+=(${input_f}phenotypeMatrix_${i}.txt)
	fi
done


${git_fold}evaluate_risk_score_run.R \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_withMedication_new.txt \
	--outFold ${fold_cl}tscore_corr2Thr0.1_relatedPhenotypes_ \
	--riskScore_file ${fold_cl}tscore_corr2Thr0.1_risk_score_relatedPhenotypes.txt \
	--names_pheno ${name_file[@]} \
	--pheno_file ${pheno_file[@]} \
	--phenoAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/phenotypeDescription.txt \
