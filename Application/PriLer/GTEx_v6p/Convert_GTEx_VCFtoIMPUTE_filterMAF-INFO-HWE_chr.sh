#!/usr/bin/sh

########################################################################################################################
# change header file, error in
# ##FORMAT=<ID=GT:,Number=1,Type=String,Description="Best Guessed Genotype with posterior probability threshold of 0.9">
# "GT:" instead of "GT"

cd /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/GTEx/phg000520.v2.GTEx_MidPoint_Imputation.genotype-calls-vcf.c1/

INPUT_FILE=GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_correctHead.vep.vcf.gz

########################################################################################################################
# write a vcf table for each chromosome
OUTPUT_FILE=GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_chr
OUTFOLD=./

for chr in $(seq 1 22)
do
	echo $chr

	vcftools --gzvcf $INPUT_FILE --chr $chr --out $OUTPUT_FILE$chr --recode  --recode-INFO-all 
	mv $OUTPUT_FILE$chr'.recode.vcf' $OUTPUT_FILE$chr'.vcf'
	# compress
	bgzip -c $OUTPUT_FILE$chr'.vcf' > $OUTPUT_FILE$chr'.vcf.gz'
	rm $OUTPUT_FILE$chr'.vcf'
	# build tabix
	tabix -p vcf $OUTPUT_FILE$chr'.vcf.gz'

	#################################################################################################################
	# convert to .gen format (IMPUTE2)
	/mnt/Software/PLINK2/plink2 --vcf $OUTPUT_FILE$chr'.vcf.gz' dosage=DS --recode oxford ref-first --out $OUTFOLD$OUTPUT_FILE$chr # use the first allele as reference
	
	# save allele frequency (refers to ALT), INFO and HWE
	bcftools query -f '%CHROM %ID %POS %REF %ALT %EXP_FREQ_A1 %IMPINFO %HW\n' $OUTPUT_FILE$chr'.vcf.gz' > $OUTFOLD$OUTPUT_FILE$chr.gen_info
	rm $OUTFOLD$OUTPUT_FILE$chr'.vcf.gz'
	rm $OUTFOLD$OUTPUT_FILE$chr'.vcf.gz.tbi'
        rm $OUTFOLD$OUTPUT_FILE$chr'.log'
	# NOTE: ref and alt same wrt vcf file: 5th column ALT 4th column REF
	
	# filter .gen file based on .gen_info
	awk '{ if($7 < 0.8 || $6 < 0.05 || $6 > 0.95 || $8 < 0.00005) { print $2}}' $OUTFOLD$OUTPUT_FILE$chr.gen_info > ${OUTFOLD}var_toremove_chr${chr}	
	/mnt/Software/PLINK2/plink2 --gen $OUTFOLD$OUTPUT_FILE$chr'.gen' --sample $OUTFOLD$OUTPUT_FILE$chr'.sample' --recode oxford  --exclude ${OUTFOLD}var_toremove_chr${chr} --out $OUTFOLD$OUTPUT_FILE$chr'_filt'
	
	rm $OUTFOLD$OUTPUT_FILE$chr'.gen'
	rm $OUTFOLD$OUTPUT_FILE$chr'.sample'
	
	# filter .gen_info file 
	awk '{ if($7 >= 0.8 && $6 >= 0.05 && $6 <= 0.95 && $8 >= 0.00005) { print $0}}' $OUTFOLD$OUTPUT_FILE$chr'.gen_info' > $OUTFOLD$OUTPUT_FILE$chr'_filt.gen_info'
	rm $OUTFOLD$OUTPUT_FILE$chr'.gen_info' 

done


 

