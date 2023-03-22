#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/PRSice2_allchr.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/PRSice2_allchr.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=100G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
id_chr=${SLURM_ARRAY_TASK_ID}

fold_input=INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/plink_format/

#### update phenotype
FILE=${fold}Genotype_CAD_UKBB.pheno
if [ -f "$FILE" ]; then
    echo "$FILE exists"
else 
    awk '{print $1,$2,$6}' ${fold}Genotype_CAD_UKBB.fam > ${fold}Genotype_CAD_UKBB.pheno
    sed -i '1i FID IID Pheno' ${fold}Genotype_CAD_UKBB.pheno
fi

### download PRSice
mkdir -p OUTPUT_GWAS/PRS/PRSice_software/
wget https://github.com/choishingwan/PRSice/releases/download/2.3.3/PRSice_linux.zip -P OUTPUT_GWAS/PRS/PRSice_software/
unzip OUTPUT_GWAS/PRS/PRSice_software/
rm OUTPUT_GWAS/PRS/PRSice_software/PRSice_linux.zip

Rscript OUTPUT_GWAS/PRS/PRSice_software/PRSice.R \
    --prsice OUTPUT_GWAS/PRS/PRSice_software/PRSice_linux \
    --base OUTPUT_GWAS/CAD_UKBB_logistic_gwas_summary.txt \
    --target ${fold_input}/chr#/Genotype_CAD_UKBB_chr# \
    --binary-target T \
    --pheno ${fold_input}Genotype_CAD_UKBB.pheno \
    --cov ${fold_input}Genotype_CAD_UKBB_covariates.txt \
    --stat OR \
    --chr CHROM \
    --bp POS \
    --snp ID \
    --or \
    --out OUTPUT_GWAS/PRS/PRS_CAD_UKBB

