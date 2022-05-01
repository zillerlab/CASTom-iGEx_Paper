#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/corr_geneSet_comb_CMC_LoF.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/corr_geneSet_comb_CMC_LoF.err
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH -t 24:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/


readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names

git_fold=/home/luciat/priler_project/

corr_file=()
sample_file=()
for i in ${cohorts[@]}
do
	sample_file+=(INPUT_DATA/Covariates/${i}.covariateMatrix_old.txt)
	corr_file+=(OUTPUT_CMC/predict_PGC/200kb/${i}/devgeno0.01_testdevgeno0/cor_custom_geneList_SCZ_LoF_GeneSets.RData)
done


Rscript /home/luciat/eQTL_PROJECT/SCRIPTS/prediction/corr_customGeneList_combine_run.R \
	--sampleAnn_file ${sample_file[@]} \
	--geneSetName SCZ_LoF_GeneSets \
	--outFold OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/ \
	--corr_cohort ${corr_file[@]}





