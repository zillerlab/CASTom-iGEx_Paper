#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/CovPheno_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/CovPheno_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=5G

module load R

path_sample=/psycl/g/mpsukb/CAD/hrc_imputation/
path_mds=/psycl/g/mpsukb/CAD/geno_qced_bf_imputation/
path_out=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/

cohort=$1
short_name=$2

if [ ${cohort} == 'MG' ]
then
	name_fold=MG_redo
else
	name_fold=${cohort}
fi

Rscript /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/RSCRIPTS/create_cov_pheno_run.R --mdsFile ${path_mds}/${name_fold}/01_qc/covariates.txt --sampleFile ${path_sample}/${cohort}/oxford/ReplaceDots/${short_name}_filtered_SampleInfos --removeSampleFile /psycl/g/mpsukb/CAD/geno_qced_bf_imputation/mergedG1toWTC/mergedG1toWTC_filtBadSamples_AllSamplesToRemove_0125.txt --cohort_name ${cohort} --outFold ${path_out}/${cohort}/ 

