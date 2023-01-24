#!/bin/bash

cohort=$1
short_name=$2
id_chr=$3

path_in=gen/output/
path_out=CAD_shared_SHIP/SCRIPTS/output/


#########################
#### filter gen file ####
#########################

awk  'FNR>1 {print $3}' ${path_out}/${cohort}/${cohort}.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${id_chr}.txt > ${path_out}/${cohort}/var_tokeep_chr${id_chr}
awk  'FNR>1 {print $3,$5}' ${path_out}/${cohort}/${cohort}.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${id_chr}.txt > ${path_out}/${cohort}/chr${id_chr}_ref.txt

# use plink to correct wrong ref/alt annotations
plink2_alpha --gen ${path_in}/${short_name}.chr${id_chr}.vcf.gz.maf005.gen.gz ref-last --sample ${path_in}/${short_name}.chr${id_chr}.vcf.gz.maf005.sample --ref-allele force ${path_out}/${cohort}/chr${id_chr}_ref.txt 2 1 --recode oxford ref-first --extract ${path_out}/${cohort}/var_tokeep_chr${id_chr} --out ${path_out}/${cohort}/${short_name}_chr${id_chr}.filtered_maf005_correct_REF_ALT

###########################
#### convert to dosage ####
###########################

converter=lucia_matrix_conversion.py

python $converter ${path_out}/${cohort}/${short_name}_chr${id_chr}.filtered_maf005_correct_REF_ALT

# check first column identical to info file, then delete it
diff <(cat ${path_out}/${cohort}/var_tokeep_chr${id_chr} )  <( awk  '{print $1}' ${path_out}/${cohort}/${short_name}_chr${id_chr}.filtered_maf005_correct_REF_ALT_matrixeQTL.geno ) > ${path_out}/${cohort}/diff_res_${id_chr}
if [ -s ${path_out}/${cohort}/diff_res_${id_chr} ]
then 
	echo ERROR: chr${id_chr} transformation different positions
else		
	# transofrm to dosage .txt
	awk  'BEGIN {OFS="\t"}; FNR>2 {print $1}' ${path_out}/${cohort}/${short_name}_chr${id_chr}.filtered_maf005_correct_REF_ALT.sample | paste -s > ${path_out}/${cohort}/samples_chr${id_chr} 
	cat <( cat ${path_out}/${cohort}/samples_chr${id_chr} ) <(cut -f1 --complement ${path_out}/${cohort}/${short_name}_chr${id_chr}.filtered_maf005_correct_REF_ALT_matrixeQTL.geno) > ${path_out}/${cohort}/Genotype_dosage_chr${id_chr}_matrix.txt
	gzip ${path_out}/${cohort}/Genotype_dosage_chr${id_chr}_matrix.txt

	# remove intermediate files
	rm ${path_out}/${cohort}/diff_res_${id_chr} ${path_out}/${cohort}/chr${id_chr}_ref.txt ${path_out}/${cohort}/var_tokeep_chr${id_chr} ${path_out}/${cohort}/samples_chr${id_chr} ${path_out}/${cohort}/${short_name}_chr${id_chr}.filtered_maf005_correct_REF_ALT_matrixeQTL.geno ${path_out}/${cohort}/${short_name}_chr${id_chr}.filtered_maf005_correct_REF_ALT.sample ${path_out}/${cohort}/${short_name}_chr${id_chr}.filtered_maf005_correct_REF_ALT.gen

fi




