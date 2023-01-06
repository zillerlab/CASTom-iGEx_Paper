#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoProc_phenosCADrelated.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoProc_phenosCADrelated.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G

module load R/3.5.3
fold=/psycl/g/mpsziller/lucia/castom_cad_scz/CAD/prediction/

# convert IDs
Rscript ${fold}filter_25214_CADproject.R

#########################
#### filter tab file ####
#########################

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/

original_samples=/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/samples_unrelated_ukb25214_ukb34217
name_pheno=(/psycl/g/mpsziller/lucia/UKBB/phenotype_data/Schunkert_phenotype_CAD/Phenotype_2017_ID10089/ukb10089.tab /psycl/g/mpsziller/lucia/UKBB/phenotype_data/Schunkert_phenotype_CAD/Phenotype_2018_ID22580/ukb22580.tab /psycl/g/mpsziller/lucia/UKBB/phenotype_data/ukb40052.tab)
id_pheno=(10089 22580 40052)

for i in $(seq ${#name_pheno[@]})
do

	phenotype_data=$(eval echo "\${name_pheno[${i}-1]}")
	awk 'NR==FNR{a[$1];next} ($1 in a)' ${original_samples} ${phenotype_data} > tmp
	# change header to be used by PHEASANT
	head -1 ${phenotype_data} > head_tochange
	sed -i 's/f./x/g' head_tochange
	sed -i 's/\./_/g' head_tochange
	sed -i 's/xeid/userId/g' head_tochange
	id=$(eval echo "\${id_pheno[${i}-1]}")

	cat head_tochange tmp > ukb${id}_project25214_filtered_britishWhiteUnrelated_pheno.tab
	rm tmp head_tochange

done

# preprocess in a unique file, include only samples in the total covariate file (further filtered)
Rscript ${fold}preProcess_phenotypes_CADrelated.R

##################
#### PHESANT #####
##################
cd /psycl/g/mpsziller/lucia/PHESANT/WAS

#modify annotation, bug
cp ../variable-info/outcome_info_final_round3.tsv ../variable-info/outcome_info_final_round3_modLT.tsv
sed -i 's/""//g' ../variable-info/outcome_info_final_round3_modLT.tsv

# modify coding file, add NA for negative values categorical
cp ../variable-info/data-coding-ordinal-info.txt  ../variable-info/data-coding-ordinal-info_modLT.txt 
sed -i 's/100327,1,,7=6,,/100327,1,,7=6|-1=NA|-3=NA,,/g' ../variable-info/data-coding-ordinal-info_modLT.txt 
sed -i 's/100346,1,,3=2,,/100346,1,,3=2|-1=NA|-3=NA,,/g' ../variable-info/data-coding-ordinal-info_modLT.txt 
cp ../variable-info/data-coding-ordinal-info_modLT.txt ../variable-info/data-coding-ordinal-info_modLT_CADrel.txt
sed -i 's/100006,1,555|1|2|3|4|5|600,,0,20082/100006,1,555|1|2|3|4|5|600,,0,20077/g' ../variable-info/data-coding-ordinal-info_modLT_CADrel.txt
sed -i 's/20082/20077/g' ../variable-info/data-coding-ordinal-info_modLT_CADrel.txt

## adjust outcome info file
Rscript ${fold}PHEASANT_adjust_outcomeinfo.R

Rscript phenomeScan.r \
	--phenofile=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/ukb_Key34217_filteredFinal_phenoCADrelated.tab \
	--variablelistfile=../variable-info/outcome_info_final_round3_modLT_CADrelatedpheno.tsv \
	--datacodingfile=../variable-info/data-coding-ordinal-info_modLT_CADrel.txt \
	--resDir=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/ \
	-o phesant_custom_scan

# annotate results
Rscript ${fold}annotate_pheno_CADrelated.R

