#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/correctREF-ALT_convertDos_UKBB_%x_%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/correctREF-ALT_convertDos_UKBB_%x_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=15G

id_split=${SLURM_ARRAY_TASK_ID}
id_chr=$1

path_in=/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/
path_out=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/

#########################
#### filter gen file ####
#########################

awk  'FNR>1 {print $2}' ${path_out}/UKBB.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${id_chr}.txt > ${path_out}/var_tokeep_chr${id_chr}_split${id_split}
awk  'FNR>1 {print $2,$5}' ${path_out}/UKBB.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${id_chr}.txt > ${path_out}/chr${id_chr}_ref_split${id_split}.txt
awk -v a=${id_split} '{ if($2 == a) { print $1} }' ${path_in}/split_samples_unrelated_ukb34217 > ${path_out}/split_samples_chr${id_chr}_split${id_split}
awk 'NR==FNR{a[$1];next} ($1 in a)' ${path_out}/split_samples_chr${id_chr}_split${id_split} ${path_in}/correct_REF_ALT/chr${id_chr}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}.samples  > ${path_out}/tmp_chr${id_chr}_split${id_split}
cat <(head -2 ${path_in}/correct_REF_ALT/chr${id_chr}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}.samples) <(cat ${path_out}/tmp_chr${id_chr}_split${id_split}) > ${path_out}/split_samples_chr${id_chr}_split${id_split}
rm  ${path_out}/tmp_chr${id_chr}_split${id_split}


# use plink to correct wrong ref/alt annotations
/psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/SOFTWARE/plink2 --gen ${path_in}/correct_REF_ALT/chr${id_chr}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_newID.gen.gz --sample ${path_in}/correct_REF_ALT/chr${id_chr}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}.samples --keep ${path_out}/split_samples_chr${id_chr}_split${id_split} --ref-allele force ${path_out}/chr${id_chr}_ref_split${id_split}.txt 2 1 --recode oxford ref-first --extract ${path_out}/var_tokeep_chr${id_chr}_split${id_split} --out ${path_out}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_correct_REF_ALT

###########################
#### convert to dosage ####
###########################

converter=/psycl/g/mpsziller/lucia/CAD/eQTL_PROJECT/PYTHON_SCRIPTS/lucia_matrix_conversion.py

python $converter ${path_out}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_correct_REF_ALT

# check first column identical to info file, then delete it
diff <(cat ${path_out}/var_tokeep_chr${id_chr}_split${id_split} )  <( awk  '{print $1}' ${path_out}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_correct_REF_ALT_matrixeQTL.geno ) > ${path_out}/diff_res_${id_chr}_split${id_split}
if [ -s ${path_out}/diff_res_${id_chr}_split${id_split} ]
then 
	echo "ERROR: chr${id_chr} for split${id_split} transformation different positions"
else		
	# transofrm to dosage .txt
	awk  'BEGIN {OFS="\t"}; FNR>2 {print $1}' ${path_out}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_correct_REF_ALT.sample | paste -s > ${path_out}/samples_chr${id_chr}_split${id_split}
	cat <( cat ${path_out}/samples_chr${id_chr}_split${id_split} ) <(cut -f1 --complement ${path_out}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_correct_REF_ALT_matrixeQTL.geno) > ${path_out}/Genotype_dosage_split${id_split}_chr${id_chr}_matrix.txt
	gzip ${path_out}/Genotype_dosage_split${id_split}_chr${id_chr}_matrix.txt

	# remove intermediate files
	rm ${path_out}/diff_res_${id_chr}_split${id_split} ${path_out}/chr${id_chr}_ref_split${id_split}.txt ${path_out}/var_tokeep_chr${id_chr}_split${id_split} ${path_out}/samples_chr${id_chr}_split${id_split} ${path_out}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_correct_REF_ALT_matrixeQTL.geno ${path_out}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_correct_REF_ALT.sample ${path_out}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_correct_REF_ALT.gen ${path_out}/split_samples_chr${id_chr}_split${id_split}

fi




