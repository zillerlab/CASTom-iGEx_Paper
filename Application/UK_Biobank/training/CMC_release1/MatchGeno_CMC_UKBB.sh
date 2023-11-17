#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/Match%x_chr%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/Match%x_chr%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/
id_chr=${SLURM_ARRAY_TASK_ID}

Rscript MatchGenotype_UKBB_REF_run.R --inputUKBB /psycl/g/mpsukb/UKBB_hrc_imputation/oxford/correct_REF_ALT/ --outputUKBB INPUT_DATA_CMC/UKBB/Genotyping_data/ --REF_name CMC --inputREF INPUT_DATA_CMC/CMC/Genotyping_data/Genotype_VariantsInfo_CMC-PGC_ --outputREF INPUT_DATA_CMC/CMC/Genotyping_data/Genotype_VariantsInfo_CMC-PGCgwas-UKBB_ --curChrom chr${id_chr} --freq_pop 0.15

