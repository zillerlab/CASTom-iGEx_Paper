#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/glm_plink_chr%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/glm_plink_chr%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=50G

id_chr=${SLURM_ARRAY_TASK_ID}
software_fold=/psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/SOFTWARE/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

in_fold=INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/plink_format/
cov_file=${in_fold}/Genotype_CAD_UKBB_covariates.txt
fam_file=${in_fold}/Genotype_CAD_UKBB.fam
out_fold=OUTPUT_GWAS/

mkdir -p ${out_fold}/chr${id_chr}/

${software_fold}plink2 \
	--fam ${fam_file} \
	--bim ${in_fold}/chr${id_chr}/Genotype_CAD_UKBB_chr${id_chr}.bim \
	--bed ${in_fold}/chr${id_chr}/Genotype_CAD_UKBB_chr${id_chr}.bed \
	--covar ${cov_file} \
	--glm \
	--parameters 1-13 \
	--out ${out_fold}chr${id_chr}/CAD_UKBB_chr${id_chr}
