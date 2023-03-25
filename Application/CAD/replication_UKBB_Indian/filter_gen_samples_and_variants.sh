#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/filter_gen_ukbb_%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/filter_gen_ukbb_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=50G


chrom=${SLURM_ARRAY_TASK_ID}
out_fold=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB_other_ancestry/
sample_fold=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB_other_ancestry/
UKBB_fold=/psycl/g/mpsukb/UKBB_hrc_imputation/
EU_geno_fold=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/
cohort=ukb_imp_chr
sample_file=${UKBB_fold}ukb34217_imp_chr1_v3_s487317.sample

# get the list of sample to include
if [ ! -f ${out_fold}samples_to_include_indian.txt ]; then
awk 'NR>1 {print $1}' ${sample_fold}covariateMatrix_latestW_202202_Indian.txt > ${out_fold}samples_to_include_indian.txt
fi

# get snpid lists
awk 'NR>1 {print $2}' ${EU_geno_fold}UKBB.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${chrom}.txt > ${out_fold}UKBB.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${chrom}_SNPID.txt 

module load qctool/2.1

qctool_v2.1-dev -g ${UKBB_fold}${cohort}${chrom}_v3.bgen \
-s ${sample_file} \
-incl-samples ${out_fold}samples_to_include_indian.txt \
-incl-snpids ${out_fold}UKBB.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${chrom}_SNPID.txt \
-omit-chromosome \
-og ${out_fold}oxford/${cohort}${chrom}_v3.Indian_matched_CAD_UKBB.gen \
-os ${out_fold}oxford/ukb34217_imp_chr1_v3_s487317.Indian_matched_CAD_UKBB.samples

# substitute correct plink format
cat ${out_fold}oxford/${cohort}${chrom}_v3.Indian_matched_CAD_UKBB.gen | cut -d ' ' --complement -f2 | awk -v a=${chrom} 'BEGIN { OFS=" " } {print a,$0}' > ${out_fold}oxford/${cohort}${chrom}_v3.Indian_matched_CAD_UKBB_newID.gen

gzip ${out_fold}oxford/${cohort}${chrom}_v3.Indian_matched_CAD_UKBB_newID.gen

# remove temporary files
rm ${out_fold}oxford/${cohort}${chrom}_v3.Indian_matched_CAD_UKBB.gen

