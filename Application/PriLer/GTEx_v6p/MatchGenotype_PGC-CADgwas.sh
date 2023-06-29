#!/usr/bin/sh

Rscript MatchGenotype_GWAS_run.R \
    --curChrom chr$1 \
    --nameInfo /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/phg000520.v2.GTEx_MidPoint_Imputation.genotype-calls-vcf.c1/GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_chr \
    --nameGeno /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/phg000520.v2.GTEx_MidPoint_Imputation.genotype-calls-vcf.c1/GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_chr \
    --nameGWAS_CAD /psycl/g/mpsziller/lucia/datasets_denbi/CAD_GWAS/cad.add.160614.website_chr \
    --nameGWAS_PGC /psycl/g/mpsziller/lucia/datasets_denbi/PGC_GWAS/Original_SCZ_variants_chr \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/