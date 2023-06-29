#!/usr/bin/sh


##########################################
### combine covariates for each tissue ###
##########################################

tissues=$(awk 'FNR>1 {print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/Tissues_Names.txt) # FNR>1 skip the first line

for t in ${tissues[@]}
do
	echo $t
	
	mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/${t}
	
done


Rscript combine_covariates_eu.R

