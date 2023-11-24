#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoProc_manual_ratioBC.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoProc_manual_ratioBC.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=50G

module load R/3.5.3

#########################
#### filter tab file ####
#########################

f=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/

# compute ratio from original values
Rscript manually_extract_Blood_count_ratios.R

original_samples=/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/split_samples_unrelated_ukb34217
name_pheno=(23895_BCratios)

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

Rscript preProcess_phenotypes_BCratio.R

##################
#### PHESANT #####
##################
f=/psycl/g/mpsukb/PHESANT/WAS/

Rscript ${f}phenomeScan.r \
    --phenofile=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/ukb23895_BCratios_filtered_britishWhiteUnrelated_pheno_final.tab \
    --variablelistfile=${f}/../variable-info/outcome_info_round3_modLT_plus_ratioBloodCount.tsv \
    --datacodingfile=${f}../variable-info/data-coding-ordinal-info_modLT.txt \
    --resDir=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/ \
    -o phesant_custom_scan_ratioBloodCount

# annotate results
Rscript annotate_pheno_ratio_blood_count.R

