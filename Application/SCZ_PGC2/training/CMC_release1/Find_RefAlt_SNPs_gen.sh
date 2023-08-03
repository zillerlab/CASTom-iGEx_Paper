#!/bin/bash
#SBATCH --job-name=corr_RF
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/find_RefAlt_snps_%A_chr%a.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/find_RefAlt_snps_%A_chr%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p hp


id_chr=${SLURM_ARRAY_TASK_ID}

path=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/SNPs/
cd $path 

# data in slurmgate processed by Laura!
awk '{print $1,$2,$3,$4,$5}' /ziller/laura/eQTL/F_DATA/FINAL_FILTERED_SNPS/filtered_chr${id_chr}_snps.gen > tmp_chr${id_chr}

# trasnform to bed file
awk '{print "chr"$1,$3-1,$3}' OFS='\t' tmp_chr${id_chr} > chr${id_chr}.bed
# match to reference genome
bedtools getfasta -fi /psycl/g/mpsziller/lucia/refData/human_genome/hg19.fa -bed chr${id_chr}.bed -fo chr${id_chr}.fa.out

perl -pe 's/\n|-|:/\t/g' chr${id_chr}.fa.out | perl -pe 's/>chr/\n/g' | awk 'BEGIN {OFS="\t"}{if(NR>=2) {print $1,$3,$4}}' > chr${id_chr}.fa.tmp
awk '{if($3=="a") {$3="A";print $0} else if($3=="t") {$3="T";print $0} else if($3=="c") {$3="C";print $0} else if($3=="g") {$3="G";print $0} else {print $0}}' chr${id_chr}.fa.tmp > chr${id_chr}.fa.tmp2
perl -pe 's/ +/\t/g' chr${id_chr}.fa.tmp2 > chr${id_chr}.reference_alleles
rm chr${id_chr}.bed chr${id_chr}.fa.out chr${id_chr}.fa.tmp chr${id_chr}.fa.tmp2

paste <(awk '{print $2}' tmp_chr${id_chr} ) <(awk 'BEGIN {FS="\t"}; {print $3}' chr${id_chr}.reference_alleles ) > chr${id_chr}_ref.txt

rm chr${id_chr}.reference_alleles tmp_chr${id_chr}

