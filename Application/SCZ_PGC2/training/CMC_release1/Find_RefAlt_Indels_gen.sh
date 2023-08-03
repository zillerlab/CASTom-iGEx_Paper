#!/bin/bash
#SBATCH --job-name=corr_RF
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/find_RefAlt_ind_%A_chr%a.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/find_RefAlt_ind_%A_chr%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p hp


id_chr=${SLURM_ARRAY_TASK_ID}

path=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/INDELS/
cd $path 

# data in slurmgate processed by Laura!
awk '{print $1,$2,$3,$4,$5}' /ziller/laura/eQTL/F_DATA/FINAL_FILTERED_INDELS/filtered_chr${id_chr}_indels.gen > tmp_chr${id_chr}

# trasnform to bed file, length depends on the INDEL dimension
awk '{print length($4)"\t"length($5)}' tmp_chr${id_chr} > dim_chr${id_chr}
# find max 
paste <(awk '{print $0}' tmp_chr${id_chr} ) <(awk '{m=$1;for(i=1;i<=NF;i++)if($i>m)m=$i;print m}' dim_chr${id_chr} ) > tmp_dim_chr${id_chr}

awk '{print "chr"$1,$3-1,$3+$6-1}' OFS='\t' tmp_dim_chr${id_chr} > chr${id_chr}.bed
# math to reference genome
bedtools getfasta -fi /psycl/g/mpsziller/lucia/refData/human_genome/hg19.fa -bed chr${id_chr}.bed -fo chr${id_chr}.fa.out

perl -pe 's/\n|-|:/\t/g' chr${id_chr}.fa.out | perl -pe 's/>chr/\n/g' | awk 'BEGIN {OFS="\t"}{if(NR>=2) {print $1,$3,$4}}' > chr${id_chr}.fa.tmp
tr '[:lower:]' '[:upper:]' < chr${id_chr}.fa.tmp > chr${id_chr}.fa.tmp2
perl -pe 's/ +/\t/g' chr${id_chr}.fa.tmp2 > chr${id_chr}.reference_alleles
rm chr${id_chr}.bed chr${id_chr}.fa.out chr${id_chr}.fa.tmp chr${id_chr}.fa.tmp2

# match with original file, if entire indel present consider that as reference
paste <(awk 'BEGIN {FS="\t"}; {print $1,$2,$3,$4,$5}' tmp_chr${id_chr} ) <(awk 'BEGIN {FS="\t"}; {print $0}' chr${id_chr}.reference_alleles ) > chr${id_chr}_ref.txt
awk '!/^$/ {if($4==$8) {print $4} else {if($5==$8) {print $5} else {print substr($8,1,1)}}}' chr${id_chr}_ref.txt > chr${id_chr}_ref

paste <(awk '{print $2}' tmp_chr${id_chr} ) <(awk 'BEGIN {FS="\t"}; {print $1}' chr${id_chr}_ref ) > chr${id_chr}_ref.txt
rm chr${id_chr}_ref dim_chr${id_chr} tmp_dim_chr${id_chr}

rm chr${id_chr}.reference_alleles tmp_chr${id_chr}

