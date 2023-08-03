#!/bin/bash
#SBATCH --job-name=filt
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/filt_maf001_info06_%A_chr%a.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/filt_maf001_info06_%A_chr%a.err
#SBATCH --mem-per-cpu=5G
#SBATCH -c 1
#SBATCH -p pe

id_chr=${SLURM_ARRAY_TASK_ID}

sample_list=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/caucasian_samples_gen.txt
info_file=/ziller/laura/eQTL/DATA/chr${id_chr}/chr${id_chr}_ALL.gen_info
maf_thr=0.01
info_thr=0.6
converter=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/PYTH_SCRIPTS/lucia_matrix_conversion.py

################
##### SNPs #####
################
input_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/SNPs/

# find variants to exclude
awk 'NR==FNR{c[$2$3]++;next};c[$2$3] > 0' ${input_fold}/filtered_chr${id_chr}_snps_caucasian.afreq ${info_file} > ${input_fold}/tmp_chr${id_chr}
awk -v a=${info_thr} '{if($5<a) {print $2}}' ${input_fold}/tmp_chr${id_chr} > ${input_fold}/rm_chr${id_chr}_info
awk -v a=${maf_thr} '{if($6<=a || $6>=1-a) {print $2}}' ${input_fold}/filtered_chr${id_chr}_snps_caucasian.afreq > ${input_fold}/rm_chr${id_chr}_maf
cat <(tail -n +2 ${input_fold}/rm_chr${id_chr}_maf) ${input_fold}/rm_chr${id_chr}_info | sort -u > ${input_fold}/rm_chr${id_chr}
rm ${input_fold}/rm_chr${id_chr}_maf ${input_fold}/rm_chr${id_chr}_info

/psycl/g/mpsziller/lucia/Software/software_slurmgate/PLINK2/plink2 --gen /ziller/laura/eQTL/F_DATA/FINAL_FILTERED_SNPS/filtered_chr${id_chr}_snps.gen --keep ${sample_list} --sample /ziller/laura/eQTL/F_DATA/CMC_MSSM-Penn-Pitt_DLPFC_DNA_imputed.sample --ref-allele force ${input_fold}/chr${id_chr}_ref.txt 2 1 --recode oxford ref-first  --exclude ${input_fold}/rm_chr${id_chr} --out ${input_fold}/filtered_chr${id_chr}_corRefAlt_snps_caucasian_maf001_info06

rm ${input_fold}/rm_chr${id_chr} ${input_fold}/tmp_chr${id_chr}

# convert to dosage
python $converter ${input_fold}/filtered_chr${id_chr}_corRefAlt_snps_caucasian_maf001_info06

# modify afreq file
awk 'NR==FNR{c[$2$3]++;next};c[$2$3] > 0' ${input_fold}/filtered_chr${id_chr}_corRefAlt_snps_caucasian_maf001_info06.gen ${input_fold}/filtered_chr${id_chr}_snps_caucasian.afreq > ${input_fold}/tmp_chr${id_chr}

paste <(awk 'BEGIN {OFS="\t"}; {print $1,$2,$3,$4,$5,$6}' ${input_fold}/tmp_chr${id_chr}) <(awk 'BEGIN {OFS="\t"}; {print $1,$2,$3,$4,$5}' ${input_fold}/filtered_chr${id_chr}_corRefAlt_snps_caucasian_maf001_info06.gen) > ${input_fold}/tmp_chr${id_chr}_refalt
awk 'BEGIN {OFS="\t"}; {if($4==$11 && $5==$10) {print $1,$2,$3,$5,$4,1-$6} else {if($4==$10 || $5==$11) {print $1,$2,$3,$4,$5,$6}}}' ${input_fold}/tmp_chr${id_chr}_refalt > ${input_fold}/new_chr${id_chr}
echo -e  "CHROM\tID\tPOS\tREF\tALT\tALT_frq" | cat - ${input_fold}/new_chr${id_chr} > ${input_fold}/filtered_chr${id_chr}_corRefAlt_snps_caucasian_maf001_info06.afreq

rm ${input_fold}/tmp_chr${id_chr}_refalt ${input_fold}/new_chr${id_chr} ${input_fold}/tmp_chr${id_chr}

echo "finished SNPs conversion"

##################
##### Indels #####
##################
input_fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/INDELS/

# find variants to exclude
awk 'NR==FNR{c[$2$3]++;next};c[$2$3] > 0' ${input_fold}/filtered_chr${id_chr}_indels_caucasian.afreq ${info_file} > ${input_fold}/tmp_chr${id_chr}
awk -v a=${info_thr} '{if($5<a) {print $2}}' ${input_fold}/tmp_chr${id_chr} > ${input_fold}/rm_chr${id_chr}_info
awk -v a=${maf_thr} '{if($6<=a || $6>=1-a) {print $2}}' ${input_fold}/filtered_chr${id_chr}_indels_caucasian.afreq > ${input_fold}/rm_chr${id_chr}_maf
cat <(tail -n +2 ${input_fold}/rm_chr${id_chr}_maf) ${input_fold}/rm_chr${id_chr}_info | sort -u > ${input_fold}/rm_chr${id_chr}
rm ${input_fold}/rm_chr${id_chr}_maf ${input_fold}/rm_chr${id_chr}_info

/psycl/g/mpsziller/lucia/Software/software_slurmgate/PLINK2/plink2 --gen /ziller/laura/eQTL/F_DATA/FINAL_FILTERED_INDELS/filtered_chr${id_chr}_indels.gen --keep ${sample_list} --sample /ziller/laura/eQTL/F_DATA/CMC_MSSM-Penn-Pitt_DLPFC_DNA_imputed.sample --ref-allele force ${input_fold}/chr${id_chr}_ref.txt 2 1 --recode oxford ref-first  --exclude ${input_fold}/rm_chr${id_chr} --out ${input_fold}/filtered_chr${id_chr}_corRefAlt_indels_caucasian_maf001_info06

rm ${input_fold}/rm_chr${id_chr} ${input_fold}/tmp_chr${id_chr}

# convert to dosage 
python $converter ${input_fold}/filtered_chr${id_chr}_corRefAlt_indels_caucasian_maf001_info06

# modify afreq file
awk 'NR==FNR{c[$2$3]++;next};c[$2$3] > 0' ${input_fold}/filtered_chr${id_chr}_corRefAlt_indels_caucasian_maf001_info06.gen ${input_fold}/filtered_chr${id_chr}_indels_caucasian.afreq > ${input_fold}/tmp_chr${id_chr}

paste <(awk 'BEGIN {OFS="\t"}; {print $1,$2,$3,$4,$5,$6}' ${input_fold}/tmp_chr${id_chr}) <(awk 'BEGIN {OFS="\t"}; {print $1,$2,$3,$4,$5}' ${input_fold}/filtered_chr${id_chr}_corRefAlt_indels_caucasian_maf001_info06.gen) > ${input_fold}/tmp_chr${id_chr}_refalt
awk 'BEGIN {OFS="\t"}; {if($4==$11 && $5==$10) {print $1,$2,$3,$5,$4,1-$6} else {if($4==$10 || $5==$11) {print $1,$2,$3,$4,$5,$6}}}' ${input_fold}/tmp_chr${id_chr}_refalt > ${input_fold}/new_chr${id_chr}
echo -e  "CHROM\tID\tPOS\tREF\tALT\tALT_frq" | cat - ${input_fold}/new_chr${id_chr} > ${input_fold}/filtered_chr${id_chr}_corRefAlt_indels_caucasian_maf001_info06.afreq

rm ${input_fold}/tmp_chr${id_chr}_refalt ${input_fold}/new_chr${id_chr} ${input_fold}/tmp_chr${id_chr}


echo "finished Indels conversion"


