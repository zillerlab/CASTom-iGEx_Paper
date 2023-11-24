#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoProc_ukb39002.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoProc_ukb39002.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=50G

module load R

#########################
#### filter tab file ####
#########################

f=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/

original_samples=/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/split_samples_unrelated_ukb34217
name_pheno=(39002)

for i in ${name_pheno[@]}
do

	phenotype_data=/psycl/g/mpsziller/lucia/UKBB/phenotype_data/ukb${i}.tab
	awk 'NR==FNR{a[$1];next} ($1 in a)' ${original_samples} ${phenotype_data} > ${f}tmp
	# change header to be used by PHEASANT
	head -1 ${phenotype_data} > ${f}head_tochange
	sed -i 's/f./x/g' ${f}head_tochange
	sed -i 's/\./_/g' ${f}head_tochange
	sed -i 's/xeid/userId/g' ${f}head_tochange

	cat ${f}head_tochange tmp > ${f}ukb${i}_filtered_britishWhiteUnrelated_pheno.tab
	rm ${f}tmp ${f}head_tochange

done

# 1 
# process total phenotype and save, exclude date and ICD9
Rscript preProcess_phenotypes_ICD9-10_OPSC4.R

# 2
# mix ICD10 + ICD9  + self reported for disease of interest (Mental)
Rscript preProcess_phenotypes_ICD9-10_mixedpheno_Psychiatric.R


