#!/bin/bash
#SBATCH -o /psycl/g/mpsukb/CAD/hrc_imputation/lucia_scripts/err_out_fold/correctREF-ALT_%x_%a.out
#SBATCH -e /psycl/g/mpsukb/CAD/hrc_imputation/lucia_scripts/err_out_fold/correctREF-ALT_%x_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load bedtools

cohort=$1
short_name=$2
id_chr=$3

#path=/psycl/g/mpsukb/CAD/hrc_imputation/${cohort}/oxford/ReplaceDots/correct_REF_ALT
path=/home/teumera/projects/Expression/CVD_MPI/CAD_shared_SHIP/SCRIPTS/SHIP-0
cd $path 

#zcat ../${short_name}_${id_chr}.Nodots_filtered_maf005.gen.gz | awk '{print $1,$2,$3,$4,$5}' > tmp_chr${id_chr}
#SHIP-0_R4a.chr8.dose.vcf.gz.maf005.gen.gz
zcat output/${short_name}.chr${id_chr}.dose.vcf.gz.maf005.gen.gz | awk '{print $1,$2,$3,$4,$5}' > tmp_chr${id_chr}

# remove duplicated lines (multialleleic position, both snps and indels)
awk 'n=x[$3]{print n"\n"$0;} {x[$3]=$0;}'  tmp_chr${id_chr} > tmp_chr${id_chr}_dupes # find duplicates based position columns
nrow=$(< tmp_chr${id_chr}_dupes wc -l)
if [ "${nrow}" != "0" ] 
then
	awk 'NR==FNR{a[$0];next} !($0 in a)' tmp_chr${id_chr}_dupes tmp_chr${id_chr} > tmp_chr${id_chr}_uniq
else
	cp tmp_chr${id_chr} tmp_chr${id_chr}_uniq
fi


#########################
### consider only snp ###
#########################

awk '{ if((length($4) == 1) && (length($5) == 1)) { print } }' tmp_chr${id_chr}_uniq > tmp_chr${id_chr}_snps
awk -v a=${id_chr} '{print "chr"a,$3-1,$3}' OFS='\t' tmp_chr${id_chr}_snps > chr${id_chr}_snps.bed

# match to reference genome
bedtools getfasta -fi /home/teumera/data/UCSC/refdata/hg19.fa -bed chr${id_chr}_snps.bed -fo chr${id_chr}_snps.fa.out
perl -pe 's/\n|-|:/\t/g' chr${id_chr}_snps.fa.out | perl -pe 's/>chr/\n/g' | awk 'BEGIN {OFS="\t"}{if(NR>=2) {print $1,$3,$4}}' > chr${id_chr}_snps.fa.tmp
awk '{if($3=="a") {$3="A";print $0} else if($3=="t") {$3="T";print $0} else if($3=="c") {$3="C";print $0} else if($3=="g") {$3="G";print $0} else {print $0}}' OFS='\t' chr${id_chr}_snps.fa.tmp > chr${id_chr}_snps.fa.tmp2
perl -pe 's/ +/\t/g'  chr${id_chr}_snps.fa.tmp2 >  chr${id_chr}_snps.reference_alleles
rm chr${id_chr}_snps.bed chr${id_chr}_snps.fa.out chr${id_chr}_snps.fa.tmp chr${id_chr}_snps.fa.tmp2

paste -d " " <(awk '{print $1,$2,$3}' tmp_chr${id_chr}_snps ) <(awk 'BEGIN {FS="\t"}; {print $3}' chr${id_chr}_snps.reference_alleles ) > chr${id_chr}_snps_ref.txt

# write alternative
paste -d " " <(awk '{print $4}' chr${id_chr}_snps_ref.txt) <(awk '{print $4,$5}' tmp_chr${id_chr}_snps) > chr${id_chr}_find_alt
paste -d " " <(awk -v a=${id_chr} 'BEGIN {OFS=" "}; {print a,$1,$2,$3,$4}' chr${id_chr}_snps_ref.txt) <(awk '!/^$/ {if($1==$2) {print $3} else {if($1==$3) {print $2}}}' chr${id_chr}_find_alt) > chr${id_chr}_snps_correct.txt
rm chr${id_chr}_find_alt chr${id_chr}_snps_ref.txt chr${id_chr}_snps.reference_alleles


###########################
### consider only indel ###
###########################

awk '{ if((length($4) > 1) || (length($5) > 1)) { print } }' tmp_chr${id_chr}_uniq > tmp_chr${id_chr}_indels
nrow=$(< tmp_chr${id_chr}_indels wc -l)
if [ "${nrow}" != "0" ] 
then
	echo INDEL PRESENT
else
	cp tmp_chr${id_chr}_indels chr${id_chr}_indels_correct.txt

fi

#################################
#### combine snps and indels ####
#################################

cat chr${id_chr}_snps_correct.txt chr${id_chr}_indels_correct.txt > chr${id_chr}.txt
sort -n -k 4 chr${id_chr}.txt > chr${id_chr}_correct.txt

rm tmp_chr${id_chr} tmp_chr${id_chr}_snps tmp_chr${id_chr}_uniq chr${id_chr}.txt chr${id_chr}_snps_correct.txt chr${id_chr}_indels_correct.txt

echo correct REF/ALT found


########################################################
### add ALT_freq, used to match with other datasets ####
########################################################

# match using alternate_ids (unique)
# NOTE: some snps_stat file have repeated position, get rid of them
#awk 'NR==FNR{a[$2];next} ($1 in a)' chr${id_chr}_correct.txt ../${short_name}_${id_chr}.Nodots_filtered.snps_stats  > filt_info_chr${id_chr}_tmp
awk 'NR==FNR{a[$2];next} ($1 in a)' chr${id_chr}_correct.txt output/${short_name}.chr${id_chr}.dose.vcf.gz.maf005.snps_stats  > filt_info_chr${id_chr}_tmp
# corrected the filter dups
#awk '!seen[$2]++' filt_info_chr${id_chr}_tmp > filt_info_chr${id_chr}
nrow=$(< tmp_chr${id_chr}_dupes wc -l)
if [ "${nrow}" != "0" ] 
then
	awk 'NR==FNR{a[$2];next} !($2 in a)' tmp_chr${id_chr}_dupes filt_info_chr${id_chr}_tmp > filt_info_chr${id_chr}
else
	cp filt_info_chr${id_chr}_tmp filt_info_chr${id_chr}
fi



paste -d " " <(awk 'BEGIN {OFS=" "}; {print $5,$6,$14,$15,$16}' filt_info_chr${id_chr}) <(awk '{print $5,$6}' chr${id_chr}_correct.txt) > tmp_chr${id_chr}

# use minor allele frequency computed from qctools, if ALT correspond to minor, keep it otherwise adjust
paste -d " " <(cat chr${id_chr}_correct.txt) <(awk -v a=0.5 '!/^$/ {if($3==a) {print $3} else {if($4==$7) {print $3} else {if($4==$6) {print 1-$3}}}}' tmp_chr${id_chr}) > chr${id_chr}_correct_altFreq.txt

rm filt_info_chr${id_chr} tmp_chr${id_chr} chr${id_chr}_correct.txt filt_info_chr${id_chr}_tmp
rm tmp_chr${id_chr}_dupes 

echo pasted ALT freq






