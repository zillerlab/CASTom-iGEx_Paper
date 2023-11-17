#!/bin/bash
#SBATCH -o /psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/err_out_fold/correctREF-ALT_%a.out
#SBATCH -e /psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/err_out_fold/correctREF-ALT_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G


module load bedtools

id_chr=${SLURM_ARRAY_TASK_ID}

path=/psycl/g/mpsukb/UKBB_hrc_imputation/
cd $path 

# remove duplicated lines (multialleleic position, both snps and indels)
awk 'n=x[$3]{print n"\n"$0;} {x[$3]=$0;}' snps_stats/ukb_imp_chr${id_chr}_v3.filtered_maf005.gen_info > oxford/correct_REF_ALT/tmp_chr${id_chr}_dupes # find duplicates based on position columns
awk 'NR==FNR{a[$0];next} !($0 in a)' oxford/correct_REF_ALT/tmp_chr${id_chr}_dupes snps_stats/ukb_imp_chr${id_chr}_v3.filtered_maf005.gen_info > oxford/correct_REF_ALT/tmp_chr${id_chr}_uniq # delete

cd oxford/correct_REF_ALT/

#########################
### consider only snp ###
#########################

awk '{ if((length($4) == 1) && (length($5) == 1)) { print } }' tmp_chr${id_chr}_uniq > tmp_chr${id_chr}_snps
awk -v a=${id_chr} '{print "chr"a,$3-1,$3}' OFS='\t' tmp_chr${id_chr}_snps > chr${id_chr}_snps.bed

# match to reference genome
bedtools getfasta -fi /psycl/g/mpsukb/refData/hg19.fa -bed chr${id_chr}_snps.bed -fo chr${id_chr}_snps.fa.out
perl -pe 's/\n|-|:/\t/g' chr${id_chr}_snps.fa.out | perl -pe 's/>chr/\n/g' | awk 'BEGIN {OFS="\t"}{if(NR>=2) {print $1,$3,$4}}' > chr${id_chr}_snps.fa.tmp
awk '{if($3=="a") {$3="A";print $0} else if($3=="t") {$3="T";print $0} else if($3=="c") {$3="C";print $0} else if($3=="g") {$3="G";print $0} else {print $0}}' OFS='\t' chr${id_chr}_snps.fa.tmp > chr${id_chr}_snps.fa.tmp2
perl -pe 's/ +/\t/g'  chr${id_chr}_snps.fa.tmp2 >  chr${id_chr}_snps.reference_alleles
rm chr${id_chr}_snps.bed chr${id_chr}_snps.fa.out chr${id_chr}_snps.fa.tmp chr${id_chr}_snps.fa.tmp2

paste <(awk '{print $1,$2,$3}' tmp_chr${id_chr}_snps ) <(awk 'BEGIN {FS="\t"}; {print $3}' chr${id_chr}_snps.reference_alleles ) > chr${id_chr}_snps_ref.txt

# write alternative
paste -d " " <(awk '{print $4}' chr${id_chr}_snps_ref.txt) <(awk '{print $4,$5}' tmp_chr${id_chr}_snps) > chr${id_chr}_find_alt
paste -d " " <(awk -v a=${id_chr} 'BEGIN {OFS=" "}; {print a,$1,$2,$3,$4}' chr${id_chr}_snps_ref.txt) <(awk '!/^$/ {if($1==$2) {print $3} else {if($1==$3) {print $2}}}' chr${id_chr}_find_alt) > chr${id_chr}_snps_correct.txt
rm chr${id_chr}_find_alt chr${id_chr}_snps_ref.txt chr${id_chr}_snps.reference_alleles


###########################
### consider only indel ###
###########################

awk '{ if((length($4) > 1) || (length($5) > 1)) { print } }' tmp_chr${id_chr}_uniq > tmp_chr${id_chr}_indels
# find max 
awk '{print length($4)"\t"length($5)}' tmp_chr${id_chr}_indels  > dim_chr${id_chr}_indels
paste <(awk '{print $0}' tmp_chr${id_chr}_indels ) <(awk '{m=$1;for(i=1;i<=NF;i++)if($i>m)m=$i;print m}' dim_chr${id_chr}_indels ) > tmp_dim_chr${id_chr}_indels
awk -v a=${id_chr} '{print "chr"a,$3-1,$3+$6-1}' OFS='\t' tmp_dim_chr${id_chr}_indels > chr${id_chr}_indels.bed

# match to reference genome
bedtools getfasta -fi /psycl/g/mpsukb/refData/hg19.fa -bed chr${id_chr}_indels.bed -fo chr${id_chr}_indels.fa.out
perl -pe 's/\n|-|:/\t/g' chr${id_chr}_indels.fa.out | perl -pe 's/>chr/\n/g' | awk 'BEGIN {OFS="\t"}{if(NR>=2) {print $1,$3,$4}}' > chr${id_chr}_indels.fa.tmp
tr '[:lower:]' '[:upper:]' < chr${id_chr}_indels.fa.tmp > chr${id_chr}_indels.fa.tmp2
perl -pe 's/ +/\t/g' chr${id_chr}_indels.fa.tmp2 > chr${id_chr}_indels.reference_alleles
rm chr${id_chr}_indels.bed chr${id_chr}_indels.fa.out chr${id_chr}_indels.fa.tmp chr${id_chr}_indels.fa.tmp2

# match with original file, if entire indel present consider that as reference
paste <(awk '{print $3}' chr${id_chr}_indels.reference_alleles ) <(awk '{m=$1;for(i=1;i<=NF;i++)if($i<m)m=$i;print m}' dim_chr${id_chr}_indels ) > chr${id_chr}_ref_small
paste <(awk 'BEGIN {FS="\t"}; {print $1,$2,$3,$4,$5}' tmp_chr${id_chr}_indels ) <(awk 'BEGIN {FS="\t"}; {print $0}' chr${id_chr}_indels.reference_alleles ) <(awk '{print substr($1, 1, $2)}' chr${id_chr}_ref_small) > chr${id_chr}_indels_ref.txt
awk '!/^$/ {if($4==$8 || $5==$8) {print $8} else {if($4==$9 || $5==$9) {print $9}}}' chr${id_chr}_indels_ref.txt > chr${id_chr}_indels_ref

paste <(awk '{print $1,$2,$3}' tmp_chr${id_chr}_indels ) <(awk 'BEGIN {FS="\t"}; {print $1}' chr${id_chr}_indels_ref ) > chr${id_chr}_indels_ref.txt
rm chr${id_chr}_indels_ref dim_chr${id_chr}_indels tmp_dim_chr${id_chr}_indels chr${id_chr}_ref_small

# write alternative
paste -d " " <(awk '{print $4}' chr${id_chr}_indels_ref.txt) <(awk '{print $4,$5}' tmp_chr${id_chr}_indels) > chr${id_chr}_find_alt
paste -d " " <(awk -v a=${id_chr} 'BEGIN {OFS=" "}; {print a,$1,$2,$3,$4}' chr${id_chr}_indels_ref.txt) <(awk '!/^$/ {if($1==$2) {print $3} else {if($1==$3) {print $2}}}' chr${id_chr}_find_alt) > chr${id_chr}_indels_correct.txt
rm chr${id_chr}_find_alt chr${id_chr}_indels_ref.txt chr${id_chr}_indels.reference_alleles


#################################
#### combine snps and indels ####
#################################

cat chr${id_chr}_snps_correct.txt chr${id_chr}_indels_correct.txt > chr${id_chr}.txt
sort -n -k 4 chr${id_chr}.txt > chr${id_chr}_correct.txt

rm tmp_chr${id_chr}_indels tmp_chr${id_chr}_snps tmp_chr${id_chr}_dupes tmp_chr${id_chr}_uniq chr${id_chr}.txt chr${id_chr}_snps_correct.txt chr${id_chr}_indels_correct.txt

echo correct REF/ALT found

########################################################
### add ALT_freq, used to match with other datasets ####
########################################################

# match using alternate_ids (unique)
# NOTE: some snps_stat file have repeated position, get rid of them
awk 'NR==FNR{a[$2];next} ($1 in a)' chr${id_chr}_correct.txt ../../snps_stats/ukb_imp_chr${id_chr}_v3.snps_stats.txt  > filt_info_chr${id_chr}_tmp
awk '!seen[$0]++' filt_info_chr${id_chr}_tmp > filt_info_chr${id_chr}

paste -d " " <(awk 'BEGIN {OFS=" "}; {print $5,$6,$14,$15,$16}' filt_info_chr${id_chr}) <(awk '{print $5,$6}' chr${id_chr}_correct.txt) > tmp_chr${id_chr}

# use minor allele frequency computed from qctools, if ALT correspond to minor, keep it otherwise adjust
paste -d " " <(cat chr${id_chr}_correct.txt) <(awk -v a=0.5 '!/^$/ {if($3==a) {print $3} else {if($4==$7) {print $3} else {if($4==$6) {print 1-$3}}}}' tmp_chr${id_chr}) > chr${id_chr}_correct_altFreq.txt

rm filt_info_chr${id_chr} tmp_chr${id_chr} chr${id_chr}_correct.txt filt_info_chr${id_chr}_tmp

echo pasted ALT freq





