#!/usr/bin/sh


##########################################
### combine covariates for each tissue ###
##########################################

tissues=$(awk 'FNR>1 {print $1}' /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/Tissues_Names.txt) # FNR>1 skip the first line

# cd /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Covariates/

#for t in ${tissues[@]}
#do
#	echo $t
#	
#	mkdir ${t}
#	
#done


Rscript /mnt/lucia/eQTL_PROJECT_GTEx/RSCRIPTS/combine_covariates_eu.R

