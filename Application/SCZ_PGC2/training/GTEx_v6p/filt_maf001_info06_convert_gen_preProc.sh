#!/usr/bin/sh

# list of european samples
awk '{if ($6 == 3) print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/SampleGeno_Info.txt  > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/SampleGeno_european.txt

INPUT_FILE=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/phg000520.v2.GTEx_MidPoint_Imputation.genotype-calls-vcf.c1/GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_correctHead.vep.vcf.gz
OUTFOLD=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/phg000520.v2.GTEx_MidPoint_Imputation.genotype-calls-vcf.c1/

# extract INFO and HW for all the chromosomes
bcftools query -f '%CHROM %ID %POS %REF %ALT %EXP_FREQ_A1 %IMPINFO %HW\n' $INPUT_FILE > ${OUTFOLD}/tmp.INFO

# add header
echo -e  "CHROM ID POS REF ALT EXP_FREQ_A1 IMPINFO HW" | cat - ${OUTFOLD}/tmp.INFO > ${OUTFOLD}/GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_correctHead.INFO
rm ${OUTFOLD}/tmp.INFO

# chancge vcf samples name from _1 to -1
cp ${INPUT_FILE} ${OUTFOLD}GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_correctHead.vep.newsamples.vcf.gz

gzip -d ${OUTFOLD}GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_correctHead.vep.newsamples.vcf.gz
sed -i -e '/#CHROM/s/_1/-1/g' ${OUTFOLD}GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_correctHead.vep.newsamples.vcf
gzip ${OUTFOLD}GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_correctHead.vep.newsamples.vcf

sed -e 's/_1/-1/g' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/SampleGeno_european.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/SampleGeno_european_newid.txt
