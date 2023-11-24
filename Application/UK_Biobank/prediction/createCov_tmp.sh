#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/createCovFile_%x_%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/createCovFile_%x_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=5G


path_in=/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/
path_out=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/

for i in $(seq 100)
do
	awk -v a=${i} '{ if($2 == a) { print $1} }' ${path_in}/split_samples_unrelated_ukb34217 > ${path_out}/samples_split${i}
	paste -d "\t" <(awk '{print "X"$1}' ${path_out}/samples_split${i}) <(awk '{print $1}' ${path_out}/samples_split${i}) > ${path_out}/covariates_split${i}.txt
	cat <( echo -e "Individual_ID\tgenoSample_ID") ${path_out}/covariates_split${i}.txt > ${path_out}/covariates_split${i}_tmp.txt
	rm ${path_out}/covariates_split${i}.txt ${path_out}/samples_split${i}

done

# all together 
paste -d "\t" <(awk '{print "X"$1}' ${path_in}/split_samples_unrelated_ukb34217) <(awk '{print $1}' ${path_in}/split_samples_unrelated_ukb34217) > ${path_out}/covariates.txt
cat <( echo -e "Individual_ID\tgenoSample_ID") ${path_out}/covariates.txt > ${path_out}/covariates_tmp.txt
rm ${path_out}/covariates_tmp.txt
