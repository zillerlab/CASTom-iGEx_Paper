#!/bin/bash
#SBATCH --job-name=freq
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/freq_snps_%A_chr%a.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/freq_snps_%A_chr%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p hp


# compute allele frequence for a predifined population
id_chr=${SLURM_ARRAY_TASK_ID}
SNPs_path=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/SNPs/
INDELS_path=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/INDELS/

if [ -v $1 ]
then

	##### snps #####
	/psycl/g/mpsziller/lucia/Software/software_slurmgate/PLINK2/plink2 --gen ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.gen --sample ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.sample --freq --out ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps

	# correct ouput file, REF and ALT inverted by PLINK
	awk '{print $1,$2,$4,$3,1-$5}' OFS='\t' ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.afreq > ${SNPs_path}tmp_chr${id_chr}
	
	echo "$(tail -n +2 ${SNPs_path}tmp_chr${id_chr})" > ${SNPs_path}tmp_chr${id_chr}
	
	paste <(awk 'BEGIN{OFS="\t"}; {print $1,$2}' ${SNPs_path}tmp_chr${id_chr} ) <(awk 'BEGIN{OFS="\t"}; {print $3}' ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.snppos ) <(awk 'BEGIN{OFS="\t"}; {print $3,$4,$5}' ${SNPs_path}tmp_chr${id_chr} ) > ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.afreq
	
	echo -e  "CHROM\tID\tPOS\tREF\tALT\tALT_frq" | cat - ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.afreq  > ${SNPs_path}tmp_chr${id_chr}
	mv ${SNPs_path}tmp_chr${id_chr} ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.afreq
	rm ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.log
	

	##### indels #####
	/psycl/g/mpsziller/lucia/Software/software_slurmgate/PLINK2/plink2 --gen ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.gen --sample ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.sample --freq --out ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels
	
	# correct ouput file, REF and ALT inverted by PLINK
	awk '{print $1,$2,$4,$3,1-$5}' OFS='\t' ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.afreq > ${INDELS_path}tmp_chr${id_chr}
	
	echo "$(tail -n +2 ${INDELS_path}tmp_chr${id_chr})" > ${INDELS_path}tmp_chr${id_chr}
	
	paste <(awk 'BEGIN{OFS="\t"}; {print $1,$2}' ${INDELS_path}tmp_chr${id_chr} ) <(awk 'BEGIN{OFS="\t"}; {print $3}' ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.snppos ) <(awk 'BEGIN{OFS="\t"}; {print $3,$4,$5}' ${INDELS_path}tmp_chr${id_chr} ) > ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.afreq
	
	echo -e  "CHROM\tID\tPOS\tREF\tALT\tALT_frq" | cat - ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.afreq  > ${INDELS_path}tmp_chr${id_chr}
	mv ${INDELS_path}tmp_chr${id_chr} ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.afreq
	rm ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.log

else
	sample_list=$1
	name_file=$2	

	##### snps #####
	/psycl/g/mpsziller/lucia/Software/software_slurmgate/PLINK2/plink2 --gen ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.gen --keep ${sample_list} --sample ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.sample --freq  --out ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps_${name_file}

	# correct ouput file, REF and ALT inverted by PLINK
	awk '{print $1,$2,$4,$3,1-$5}' OFS='\t' ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps_${name_file}.afreq > ${SNPs_path}tmp_chr${id_chr}_${name_file}
	
	echo "$(tail -n +2 ${SNPs_path}tmp_chr${id_chr}_${name_file})" > ${SNPs_path}tmp_chr${id_chr}_${name_file}
	
	paste <(awk 'BEGIN{OFS="\t"}; {print $1,$2}' ${SNPs_path}tmp_chr${id_chr}_${name_file} ) <(awk 'BEGIN{OFS="\t"}; {print $3}' ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps.snppos ) <(awk 'BEGIN{OFS="\t"}; {print $3,$4,$5}' ${SNPs_path}tmp_chr${id_chr}_${name_file} ) > ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps_${name_file}.afreq
	
	echo -e  "CHROM\tID\tPOS\tREF\tALT\tALT_frq" | cat - ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps_${name_file}.afreq  > ${SNPs_path}tmp_chr${id_chr}_${name_file}
	mv ${SNPs_path}tmp_chr${id_chr}_${name_file} ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps_${name_file}.afreq
	rm ${SNPs_path}filtered_chr${id_chr}_corRefAlt_snps_${name_file}.log
	

	##### indels #####
	/psycl/g/mpsziller/lucia/Software/software_slurmgate/PLINK2/plink2 --gen ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.gen --keep ${sample_list} --sample ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.sample --freq --out ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels_${name_file}
	
	# correct ouput file, REF and ALT inverted by PLINK
	awk '{print $1,$2,$4,$3,1-$5}' OFS='\t' ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels_${name_file}.afreq > ${INDELS_path}tmp_chr${id_chr}_${name_file}
	
	echo "$(tail -n +2 ${INDELS_path}tmp_chr${id_chr}_${name_file})" > ${INDELS_path}tmp_chr${id_chr}_${name_file}
	
	paste <(awk 'BEGIN{OFS="\t"}; {print $1,$2}' ${INDELS_path}tmp_chr${id_chr}_${name_file} ) <(awk 'BEGIN{OFS="\t"}; {print $3}' ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels.snppos ) <(awk 'BEGIN{OFS="\t"}; {print $3,$4,$5}' ${INDELS_path}tmp_chr${id_chr}_${name_file} ) > ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels_${name_file}.afreq
	
	echo -e  "CHROM\tID\tPOS\tREF\tALT\tALT_frq" | cat - ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels_${name_file}.afreq  > ${INDELS_path}tmp_chr${id_chr}_${name_file}
	mv ${INDELS_path}tmp_chr${id_chr}_${name_file} ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels_${name_file}.afreq
	rm ${INDELS_path}filtered_chr${id_chr}_corRefAlt_indels_${name_file}.log

fi
