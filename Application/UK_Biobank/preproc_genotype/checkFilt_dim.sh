#!/bin/bash
#SBATCH -o checkFilt005_%a.out
#SBATCH -e checkFilt005_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G 

i=${SLURM_ARRAY_TASK_ID}

# save final report for number of snps UKBB

cd /psycl/g/mpsukb/UKBB_hrc_imputation/
# zcat oxford/ukb_imp_chr${i}_v3.filtered_maf005.gen.gz | awk '{print $1,$2,$3,$4,$5}' > snps_stats/ukb_imp_chr${i}_v3.filtered_maf005.gen_info

Rscript checkDimension_filt_run.R --filt_pos snps_stats/ukb_imp_chr_${i}_v3_snps_qc_filter_maf005_out.txt --original snps_stats/ukb_mfi_chr${i}_v3.txt --final snps_stats/ukb_imp_chr${i}_v3.filtered_maf005.gen_info --output snps_stats/checkFilt_chr${i}_maf005.txt


