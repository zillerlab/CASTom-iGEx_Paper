#!/bin/bash
#SBATCH -o /psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/err_out_fold/%x_split%a.out
#SBATCH -e /psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/err_out_fold/%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=8500MB

module load qctool/2.1

id_chr=$1
id_split=${SLURM_ARRAY_TASK_ID}
nsplit=100

path=/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/
cd $path 

mkdir -p correct_REF_ALT/chr${id_chr}

# split sample file in 100 files
if ([ "${id_chr}" -eq 1 ] && [ "${id_split}" -eq 1 ])
then
	awk 'FNR>2 {print $1}' ukb34217_imp_chr1_v3_s487317.filtered.sample > tmp_sample
	nsamples=$(wc -l tmp_sample | awk '{print $1}')	
	nlen=$((${nsamples}/${nsplit}))
	touch tmp_indx
	for i in $(seq ${nsplit})
	do	
		cat tmp_indx <( printf "$i"'%.0s\n' $(seq ${nlen}) ) >> tmp_indx
	done
	# correct for the final part if some samples are missing
	nrow_split=$(wc -l tmp_indx | awk '{print $1}')	
	if [ "${nrow_split}" != "${nsamples}" ]
	then
		diff_val=$((${nsamples} - ${nrow_split}))
		cat tmp_indx <( printf "$nsplit"'%.0s\n' $(seq ${diff_val}) ) >> tmp_indx
	fi
	
	paste -d "\t" <(cat tmp_sample) <(cat tmp_indx) > split_samples_ukb34217
	rm tmp_indx tmp_sample
fi

awk -v a=${id_split} '{ if($2 == a) { print $1} }' split_samples_ukb34217 > tmp_split${id_split}_chr${id_chr}

qctool_v2.1-dev -g ukb_imp_chr${id_chr}_v3.filtered_maf005.gen.gz -s ukb34217_imp_chr1_v3_s487317.filtered.sample -incl-samples tmp_split${id_split}_chr${id_chr} -omit-chromosome  -og correct_REF_ALT/chr${id_chr}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}.gen -os correct_REF_ALT/chr${id_chr}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}.samples

# substitute correct plink format
cat correct_REF_ALT/chr${id_chr}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}.gen | cut -d ' ' --complement -f2 | awk -v a=${id_chr} 'BEGIN { OFS=" " } {print a,$0}' > correct_REF_ALT/chr${id_chr}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_newID.gen

gzip correct_REF_ALT/chr${id_chr}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}_newID.gen

# remove temporary files
rm tmp_split${id_split}_chr${id_chr} correct_REF_ALT/chr${id_chr}/ukb_imp_chr${id_chr}_v3.filtered_maf005_splitSamples${id_split}.gen







