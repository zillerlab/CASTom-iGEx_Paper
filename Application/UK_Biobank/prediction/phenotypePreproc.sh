#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoProc.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoProc.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=50G

module load R

#########################
#### filter tab file ####
#########################

f=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates

original_samples=/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/split_samples_unrelated_ukb34217
name_pheno=(23895 38354)

for i in ${name_pheno[@]}
do

	phenotype_data=/psycl/g/mpsziller/lucia/UKBB/phenotype_data/ukb${i}.tab
	awk 'NR==FNR{a[$1];next} ($1 in a)' ${original_samples} ${phenotype_data} > ${f}tmp
	# change header to be used by PHEASANT
	head -1 ${phenotype_data} > ${f}head_tochange
	sed -i 's/f./x/g' ${f}head_tochange
	sed -i 's/\./_/g' ${f}head_tochange
	sed -i 's/xeid/userId/g' ${f}head_tochange

	cat ${f}head_tochange ${f}tmp > ${f}ukb${i}_filtered_britishWhiteUnrelated_pheno.tab
	rm ${f}tmp ${f}head_tochange

done
# preprocess in a unique file, include only samples in the total covariate file (further filtered)
Rscript preProcess_phenotypes.R

##################
#### PHESANT #####
##################
f=/psycl/g/mpsukb/PHESANT/WAS/

# modify annotation, bug
cp ${f}/../variable-info/outcome_info_final_round3.tsv ${f}/../variable-info/outcome_info_final_round3_modLT.tsv
sed -i 's/""//g' ${f}/../variable-info/outcome_info_final_round3_modLT.tsv

# modify coding file, add NA for negative values categorical
cp ${f}/../variable-info/data-coding-ordinal-info.txt  ${f}/../variable-info/data-coding-ordinal-info_modLT.txt 
sed -i 's/100327,1,,7=6,,/100327,1,,7=6|-1=NA|-3=NA,,/g' ${f}/../variable-info/data-coding-ordinal-info_modLT.txt 
sed -i 's/100346,1,,3=2,,/100346,1,,3=2|-1=NA|-3=NA,,/g' ${f}/../variable-info/data-coding-ordinal-info_modLT.txt 

# adjust outcome info file
Rscript PHEASANT_adjust_outcomeinfo.R

Rscript ${f}/phenomeScan.r \
    --phenofile=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/ukb_Key34217_filteredFinal_pheno.tab \
    --variablelistfile=${f}/../variable-info/outcome_info_final_round3_modLT.tsv \
    --datacodingfile=${f}/../variable-info/data-coding-ordinal-info_modLT.txt \
    --resDir=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/ \
    -o phesant_custom_scan

# annotate results
Rscript annotate_pheno.R
