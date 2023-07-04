#!/bin/bash


i=$1

file_info=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_chr${i}.txt
file_1000GP=/psycl/g/mpsziller/lucia/refData/1000GP_Phase3/1000GP_Phase3_chr${i}
outfile=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/randomGWAS/1000GP_Phase3_chr${i}_filt

#file_info=/ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/Genotype_VariantsInfo_CMC-PGC_chr${i}.txt
#file_1000GP=/ziller/lucia/refData/1000GP_Phase3/1000GP_Phase3_chr${i}
#outfile=/ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/randomGWAS/1000GP_Phase3_chr${i}_filt

awk 'NR==FNR{c[$2]++;next};c[$3] == 1' ${file_info} <(zcat ${file_1000GP}.legend.gz  | tail -n +2 | cat -n) > ${outfile}.tmp

# save first column and recreate normal output
awk '{print $1}' ${outfile}.tmp > ${outfile}tmp_id${i}
cut -f2- ${outfile}.tmp > ${outfile}.legend
( echo -e "id position a0 a1 TYPE AFR AMR EAS EUR SAS ALL"; cat ${outfile}.legend ) >${outfile}new_${i}
mv ${outfile}new_${i} ${outfile}.legend
rm ${outfile}.tmp 
gzip ${outfile}.legend

# fitler hap file based on tmp_id${i}
awk 'NR==FNR {a[$1]; next}; FNR in a' ${outfile}tmp_id${i} <(zcat ${file_1000GP}.hap.gz) > ${outfile}.hap
gzip ${outfile}.hap

rm ${outfile}tmp_id${i}

