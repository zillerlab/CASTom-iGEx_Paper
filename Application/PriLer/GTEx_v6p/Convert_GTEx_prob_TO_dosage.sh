#!/usr/bin/sh



chr=$1

genfile='/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/phg000520.v2.GTEx_MidPoint_Imputation.genotype-calls-vcf.c1/GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_chr'${chr}'_filt'

#######################################
# convert to eqtl standard format

converter=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/PYTHON_SCRIPTS/lucia_matrix_conversion.py

python $converter $genfile

###############
echo "chr $chr finished"
##############

