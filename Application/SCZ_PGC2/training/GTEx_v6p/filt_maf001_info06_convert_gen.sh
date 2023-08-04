#!/usr/bin/sh

converter=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/PYTHON_SCRIPTS/lucia_matrix_conversion.py

cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/phg000520.v2.GTEx_MidPoint_Imputation.genotype-calls-vcf.c1/

INPUT_FILE=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/phg000520.v2.GTEx_MidPoint_Imputation.genotype-calls-vcf.c1/GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_correctHead.vep.newsamples.vcf.gz
OUTPUT_FILE=GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_chr
# OUTPUT_DOS=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/
id_chr=$1

# filter INFO file for 1 chromosome
awk -v a=${id_chr} '{if($1 == a) print}' GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_correctHead.INFO > ${OUTPUT_FILE}${id_chr}.INFO

# compute freq using plink for only european
/psycl/g/mpsziller/lucia/Software/software_denbi/PLINK2/plink2 --vcf ${INPUT_FILE}  dosage=DS --chr ${id_chr} --keep /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/SampleGeno_european_newid.txt  --freq --out ${OUTPUT_FILE}${id_chr}
paste -d ' ' <(cat ${OUTPUT_FILE}${id_chr}.INFO) <(awk 'FNR>1 {print $5}' ${OUTPUT_FILE}${id_chr}.afreq) > ${OUTPUT_FILE}${id_chr}.gen_info

# find duplicated positions
awk 'n=x[$3]{print n"\n"$0;} {x[$3]=$0;}' ${OUTPUT_FILE}${id_chr}.gen_info > ${OUTPUT_FILE}${id_chr}.gen_info_dupes # find duplicates based on position columns
awk 'NR==FNR{a[$0];next} !($0 in a)' ${OUTPUT_FILE}${id_chr}.gen_info_dupes ${OUTPUT_FILE}${id_chr}.gen_info > ${OUTPUT_FILE}${id_chr}.gen_info_uniq
# filter based on maf and info
awk '{ if($7 >= 0.6 && $9 >=0.01 && $9 <=0.99 ) print}' ${OUTPUT_FILE}${id_chr}.gen_info_uniq > ${OUTPUT_FILE}${id_chr}_filt_caucasian_maf001_info06.gen_info
rm ${OUTPUT_FILE}${id_chr}.gen_info_uniq ${OUTPUT_FILE}${id_chr}.gen_info_dupes ${OUTPUT_FILE}${id_chr}.gen_info ${OUTPUT_FILE}${id_chr}.afreq ${OUTPUT_FILE}${id_chr}.INFO ${OUTPUT_FILE}${id_chr}.log

awk '{print $2}' ${OUTPUT_FILE}${id_chr}_filt_caucasian_maf001_info06.gen_info > var_to_keep_chr${id_chr}

# use plink2 to convert vcf to gen, filter samples + snps + chr
/psycl/g/mpsziller/lucia/Software/software_denbi/PLINK2/plink2 --vcf ${INPUT_FILE} dosage=DS --chr ${id_chr} --keep /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/SampleGeno_european_newid.txt --recode oxford ref-first  --extract var_to_keep_chr${id_chr} --out ${OUTPUT_FILE}${id_chr}_filt_caucasian_maf001_info06


# use python to convert to dosage
python $converter ${OUTPUT_FILE}${id_chr}_filt_caucasian_maf001_info06

rm var_to_keep_chr${id_chr} ${OUTPUT_FILE}${id_chr}_filt_caucasian_maf001_info06.log ${OUTPUT_FILE}${id_chr}_filt_caucasian_maf001_info06.gen

echo "finished vcf conversion"




