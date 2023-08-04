#!/bin/bash
#SBATCH -o /psycl/g/mpsukb/CAD/hrc_imputation/lucia_scripts/err_out_fold/changeGen_%x_%a.out
#SBATCH -e /psycl/g/mpsukb/CAD/hrc_imputation/lucia_scripts/err_out_fold/changeGen_%x_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G


cohort=$1
short_name=$2

id_chr=${SLURM_ARRAY_TASK_ID}

# modify gen file, first column must be chr, second column unique id
cd /psycl/g/mpsukb/CAD/hrc_imputation/
mkdir -p ${cohort}/oxford/ReplaceDots/correct_REF_ALT/

zcat ${cohort}/oxford/ReplaceDots/${short_name}_${id_chr}.Nodots_filtered_maf005.gen.gz | cut -d ' ' --complement -f2 | awk -v a=${id_chr} 'BEGIN { OFS=" " } {print a,$0}' > ${cohort}/oxford/ReplaceDots/correct_REF_ALT/${short_name}_${id_chr}.Nodots_filtered_maf005_newID.gen
  
gzip ${cohort}/oxford/ReplaceDots/correct_REF_ALT/${short_name}_${id_chr}.Nodots_filtered_maf005_newID.gen

