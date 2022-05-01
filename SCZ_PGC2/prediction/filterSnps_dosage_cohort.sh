#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/filterSNPs_dosage_%x_chr%a.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/filterSNPs_dosage_%x_chr%a.err
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH -t 5:00:00


id_chr=${SLURM_ARRAY_TASK_ID}
id_c=$1

readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")
input_dir=//home/pgcdac/DWFV2CJb8Piv_0116_pgc_data/scz/wave2/v1/dasuqc1_${c}-qc.ch.fl/qc1
output_dir=/home/luciat/eQTL_PROJECT/INPUT_DATA/Genotyping_data/
region_index=$(tail +2 /home/pgcdac/DWFV2CJb8Piv_0116_pgc_data/scz/wave2/v1/reference_info)

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_${id_chr}
touch ${TMPDIR}/tmp_${id_c}_${id_chr}/tmp_${c}_${id_chr}
cd ${TMPDIR}/tmp_${id_c}_${id_chr}/

for i in ${region_index[@]}
do
	if [[ ${i} == *"chr${id_chr}_"* ]]
	then
	echo ${i}
	cp ${input_dir}/dos_${c}-qc.ch.fl.${i}.out.dosage.map ./
	cp ${input_dir}/dos_${c}-qc.ch.fl.${i}.out.dosage.gz ./
	cp ${input_dir}/dos_${c}-qc.ch.fl.${i}.out.dosage.fam ./
	
	#### NOTE: do not filter for missingness or hwe, use GWAS criteria
	/home/luciat/Software/plink2 --import-dosage dos_${c}-qc.ch.fl.${i}.out.dosage.gz --fam dos_${c}-qc.ch.fl.${i}.out.dosage.fam --map dos_${c}-qc.ch.fl.${i}.out.dosage.map --missing --import-dosage-certainty 0.8 --out tmp_${c}_${i}
	# save snps id with correct filtering
	#awk '{if($10<0.00001) {print $2}}' OFS='\t' tmp_${c}_${i}.hardy > rm_snps_hardy
	#awk '{if($5>0.02) {print $2}}' OFS='\t' tmp_${c}_${i}.vmiss > rm_snps_miss
	awk '{if($4-$3<20) {print $2}}' OFS='\t' tmp_${c}_${i}.vmiss > rm_snps_misscount

	/home/luciat/Software/plink1.9/plink --dosage dos_${c}-qc.ch.fl.${i}.out.dosage.gz --fam dos_${c}-qc.ch.fl.${i}.out.dosage.fam --allow-no-sex --map dos_${c}-qc.ch.fl.${i}.out.dosage.map  --out tmp_${c}_${i}

	awk '{if($6<=0.99 && $6>=0.01 && $7>=0.6) {print $1,$2,$3,$4,$5,$6,$7}}' OFS='\t' tmp_${c}_${i}.assoc.dosage > dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06
	## remove snps with HWE<10^-5 and missingness>=0.02
	#awk 'NR==FNR{c[$1]++;next}; !c[$2] > 0' rm_snps_hardy dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06 > dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_hwe000001
	#awk 'NR==FNR{c[$1]++;next}; !c[$2] > 0' rm_snps_miss dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_hwe000001 > dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_hwe000001_miss002
	
	# remove snps not present in at least 20 samples
	awk 'NR==FNR{c[$1]++;next}; !c[$2] > 0' rm_snps_misscount dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06 > dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20
	
	# remove duplicated lines (multialleleic position, both snps and indels)
	awk 'n=x[$3]{print n"\n"$0;} {x[$3]=$0;}' dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20 > dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20_dupes 

	if [ -s "dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20_dupes" ]
	then 
	awk 'NR==FNR{a[$0];next} !($0 in a)' dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20_dupes dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20 > dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20_uniq
	else
	cp dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20 dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20_uniq
	fi 	
	rm dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06 dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20 dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20_dupes tmp_${c}_${i}* rm_snps*
	cat dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20_uniq >> tmp_${c}_${id_chr}
	rm dos_${c}-qc.ch.fl.${i}.out.dosage.filt_maf001_info06_misscount20_uniq
	fi
done

echo -e  "CHROM\tID\tPOS\tA1\tA2\tA1_frq\tINFO" | cat - tmp_${c}_${id_chr}  > ${output_dir}/dos_${c}-qc.chr${id_chr}.out.dosage.filt_maf001_info06_misscount20
gzip ${output_dir}/dos_${c}-qc.chr${id_chr}.out.dosage.filt_maf001_info06_misscount20
rm -r ${TMPDIR}/tmp_${id_c}_${id_chr}




