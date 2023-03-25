#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/correctREF-ALT_convertDos_UKBB_Indian_%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/correctREF-ALT_convertDos_UKBB_Indian_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=50G

id_chr=${SLURM_ARRAY_TASK_ID}

EU_geno_fold=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/
out_fold=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB_other_ancestry/

awk  'FNR>1 {print $2,$5}' ${EU_geno_fold}/UKBB.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${id_chr}.txt > ${out_fold}/chr${id_chr}_ref
awk  'FNR>1 {print $2}' ${EU_geno_fold}/UKBB.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${id_chr}.txt > ${out_fold}/chr${id_chr}_var  

# use plink to correct wrong ref/alt annotations
/psycl/g/mpsziller/lucia/UKBB/rawData/SOFTWARE/plink2 \
--gen ${out_fold}/oxford/ukb_imp_chr${id_chr}_v3.Indian_matched_CAD_UKBB_newID.gen.gz \
--sample ${out_fold}/oxford/ukb34217_imp_chr1_v3_s487317.Indian_matched_CAD_UKBB.samples \
--ref-allele force ${out_fold}/chr${id_chr}_ref 2 1 \
--recode oxford ref-first \
--out ${out_fold}/oxford/ukb_imp_chr${id_chr}_v3.Indian_matched_CAD_UKBB_newID_correct_REF_ALT

###########################
#### convert to dosage ####
###########################

converter=/psycl/g/mpsziller/lucia/CAD/eQTL_PROJECT/PYTHON_SCRIPTS/lucia_matrix_conversion.py

python $converter ${out_fold}/oxford/ukb_imp_chr${id_chr}_v3.Indian_matched_CAD_UKBB_newID_correct_REF_ALT

# check first column identical to info file, then delete it
diff <(cat ${out_fold}/chr${id_chr}_var )  <( awk  '{print $1}' ${out_fold}/oxford/ukb_imp_chr${id_chr}_v3.Indian_matched_CAD_UKBB_newID_correct_REF_ALT_matrixeQTL.geno ) > ${out_fold}/diff_res_${id_chr}
if [ -s ${out_fold}/diff_res_${id_chr} ]
then 
	echo "ERROR: chr${id_chr} transformation different positions"
else		
	# transofrm to dosage .txt
	awk  'BEGIN {OFS="\t"}; FNR>2 {print $1}' ${out_fold}/oxford/ukb34217_imp_chr1_v3_s487317.Indian_matched_CAD_UKBB.samples | paste -s > ${out_fold}/samples_chr${id_chr}
	cat <( cat ${out_fold}/samples_chr${id_chr} ) <(cut -f1 --complement ${out_fold}/oxford/ukb_imp_chr${id_chr}_v3.Indian_matched_CAD_UKBB_newID_correct_REF_ALT_matrixeQTL.geno) > ${out_fold}/Genotype_dosage_chr${id_chr}_matrix.txt
	gzip ${out_fold}/Genotype_dosage_chr${id_chr}_matrix.txt

	# remove intermediate files
	rm ${out_fold}/diff_res_${id_chr} ${out_fold}/chr${id_chr}_ref ${out_fold}/chr${id_chr}_var ${out_fold}/oxford/ukb_imp_chr${id_chr}_v3.Indian_matched_CAD_UKBB_newID_correct_REF_ALT_matrixeQTL.geno ${out_fold}/oxford/ukb_imp_chr${id_chr}_v3.Indian_matched_CAD_UKBB_newID_correct_REF_ALT.gen ${out_fold}/samples_chr${id_chr} ${out_fold}/oxford/ukb_imp_chr${id_chr}_v3.Indian_matched_CAD_UKBB_newID_correct_REF_ALT.log ${out_fold}/oxford/ukb_imp_chr${id_chr}_v3.Indian_matched_CAD_UKBB_newID_correct_REF_ALT.sample

fi


