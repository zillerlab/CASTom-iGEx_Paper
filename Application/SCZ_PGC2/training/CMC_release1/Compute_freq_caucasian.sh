#!/bin/bash
#SBATCH --job-name=freq
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/freq_caucasian_%A_chr%a.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/freq_caucasian_%A_chr%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p pe

# compute allele frequence for a predifined population (original data not filtered or cannotation corrected)
id_chr=${SLURM_ARRAY_TASK_ID}

# data in slurmgate processed by Laura!
SNPs_path=/ziller/laura/eQTL/F_DATA/FINAL_FILTERED_SNPS/
INDELS_path=/ziller/laura/eQTL/F_DATA/FINAL_FILTERED_INDELS/
SNPs_path_out=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/SNPs/
INDELS_path_out=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/INDELS/

# create sample list of only caucasian
awk '{print $2}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt | tail -n +2 > /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/caucasian_samples.txt
# data in slurmgate processed by Laura!
cat <(head -2 /ziller/laura/eQTL/F_DATA/CMC_MSSM-Penn-Pitt_DLPFC_DNA_imputed.sample) <(awk 'NR==FNR{a[$1];next} ($1 in a)' /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/caucasian_samples.txt /ziller/laura/eQTL/F_DATA/CMC_MSSM-Penn-Pitt_DLPFC_DNA_imputed.sample)  > /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/caucasian_samples_gen.txt

sample_list=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/caucasian_samples_gen.txt
name_file=caucasian

##### snps #####
/psycl/g/mpsziller/lucia/Software/software_slurmgate/PLINK2/plink2 --gen ${SNPs_path}filtered_chr${id_chr}_snps.gen --keep ${sample_list} --sample /ziller/laura/eQTL/F_DATA/CMC_MSSM-Penn-Pitt_DLPFC_DNA_imputed.sample --freq  --out ${SNPs_path_out}filtered_chr${id_chr}_snps_${name_file}

# correct ouput file, REF and ALT inverted by PLINK
awk '{print $1,$2,$4,$3,1-$5}' OFS='\t' ${SNPs_path_out}filtered_chr${id_chr}_snps_${name_file}.afreq > ${SNPs_path_out}tmp_chr${id_chr}_${name_file}
	
# continue from here

echo "$(tail -n +2 ${SNPs_path_out}tmp_chr${id_chr}_${name_file})" > ${SNPs_path_out}tmp_chr${id_chr}_${name_file}
	
paste <(awk 'BEGIN{OFS="\t"}; {print $1,$2}' ${SNPs_path_out}tmp_chr${id_chr}_${name_file} ) <(awk 'BEGIN{OFS="\t"}; {print $3}' ${SNPs_path}filtered_chr${id_chr}_snps.gen ) <(awk 'BEGIN{OFS="\t"}; {print $3,$4,$5}' ${SNPs_path_out}tmp_chr${id_chr}_${name_file} ) > ${SNPs_path_out}filtered_chr${id_chr}_snps_${name_file}.afreq
	
echo -e  "CHROM\tID\tPOS\tREF\tALT\tALT_frq" | cat - ${SNPs_path_out}filtered_chr${id_chr}_snps_${name_file}.afreq  > ${SNPs_path_out}tmp_chr${id_chr}_${name_file}
mv ${SNPs_path_out}tmp_chr${id_chr}_${name_file} ${SNPs_path_out}filtered_chr${id_chr}_snps_${name_file}.afreq
rm ${SNPs_path_out}filtered_chr${id_chr}_snps_${name_file}.log
	

##### indels #####
/psycl/g/mpsziller/lucia/Software/software_slurmgate/PLINK2/plink2 --gen ${INDELS_path}filtered_chr${id_chr}_indels.gen --keep ${sample_list} --sample /ziller/laura/eQTL/F_DATA/CMC_MSSM-Penn-Pitt_DLPFC_DNA_imputed.sample --freq --out ${INDELS_path_out}filtered_chr${id_chr}_indels_${name_file}
	
# correct ouput file, REF and ALT inverted by PLINK
awk '{print $1,$2,$4,$3,1-$5}' OFS='\t' ${INDELS_path_out}filtered_chr${id_chr}_indels_${name_file}.afreq > ${INDELS_path_out}tmp_chr${id_chr}_${name_file}
	
echo "$(tail -n +2 ${INDELS_path_out}tmp_chr${id_chr}_${name_file})" > ${INDELS_path_out}tmp_chr${id_chr}_${name_file}
	
paste <(awk 'BEGIN{OFS="\t"}; {print $1,$2}' ${INDELS_path_out}tmp_chr${id_chr}_${name_file} ) <(awk 'BEGIN{OFS="\t"}; {print $3}' ${INDELS_path}filtered_chr${id_chr}_indels.gen ) <(awk 'BEGIN{OFS="\t"}; {print $3,$4,$5}' ${INDELS_path_out}tmp_chr${id_chr}_${name_file} ) > ${INDELS_path_out}filtered_chr${id_chr}_indels_${name_file}.afreq
	
echo -e  "CHROM\tID\tPOS\tREF\tALT\tALT_frq" | cat - ${INDELS_path_out}filtered_chr${id_chr}_indels_${name_file}.afreq  > ${INDELS_path_out}tmp_chr${id_chr}_${name_file}
mv ${INDELS_path_out}tmp_chr${id_chr}_${name_file} ${INDELS_path_out}filtered_chr${id_chr}_indels_${name_file}.afreq
rm ${INDELS_path_out}filtered_chr${id_chr}_indels_${name_file}.log



