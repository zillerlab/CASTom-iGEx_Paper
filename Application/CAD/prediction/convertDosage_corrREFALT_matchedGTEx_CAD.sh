#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/correctREF-ALT_convertDos_%x_%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/correctREF-ALT_convertDos_%x_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=20G

cohort=$1
short_name=$2
id_chr=${SLURM_ARRAY_TASK_ID}

path_in=/psycl/g/mpsukb/CAD/hrc_imputation/
path_out=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/

#########################
#### filter gen file ####
#########################

awk  'FNR>1 {print $2}' ${path_out}/${cohort}/${short_name}.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${id_chr}.txt > ${path_out}/${cohort}/var_tokeep_chr${id_chr}
awk  'FNR>1 {print $2,$5}' ${path_out}/${cohort}/${short_name}.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${id_chr}.txt > ${path_out}/${cohort}/chr${id_chr}_ref.txt

# use plink to correct wrong ref/alt annotations
/psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/SOFTWARE/plink2 --gen ${path_in}/${cohort}/oxford/ReplaceDots/correct_REF_ALT/${short_name}_${id_chr}.Nodots_filtered_maf005_newID.gen.gz --sample ${path_in}/${cohort}/oxford/ReplaceDots/${short_name}_filtered_SampleInfos --ref-allele force ${path_out}/${cohort}/chr${id_chr}_ref.txt 2 1 --recode oxford ref-first --extract ${path_out}/${cohort}/var_tokeep_chr${id_chr} --out ${path_out}/${cohort}/${short_name}_chr${id_chr}.filtered_maf005_correct_REF_ALT

###########################
#### convert to dosage ####
###########################

converter=/psycl/g/mpsziller/lucia/CAD/eQTL_PROJECT/PYTHON_SCRIPTS/lucia_matrix_conversion.py

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




