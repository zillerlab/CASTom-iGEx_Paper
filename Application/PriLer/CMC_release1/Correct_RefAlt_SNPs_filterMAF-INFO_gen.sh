#!/bin/bash
#SBATCH --job-name=corr_RF
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/cor_RefAlt_snps_%A_chr%a.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/cor_RefAlt_snps_%A_chr%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p hp


id_chr=${SLURM_ARRAY_TASK_ID}

path=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/SNPs/
cd $path 

# from slurmgate, pre-processed by Laura
awk '{print $1,$2,$3,$4,$5}' /ziller/laura/eQTL/F_DATA/FINAL_FILTERED_SNPS/filtered_chr${id_chr}_snps.gen > tmp_chr${id_chr}

## trasform to bed file
awk '{print "chr"$1,$3-1,$3}' OFS='\t' tmp_chr${id_chr} > chr${id_chr}.bed
## math to reference genome
bedtools getfasta -fi /ziller/ref_data/genomes/Hs/hg19/bwa_idx/hg19.fa -bed chr${id_chr}.bed -fo chr${id_chr}.fa.out

perl -pe 's/\n|-|:/\t/g' chr${id_chr}.fa.out | perl -pe 's/>chr/\n/g' | awk 'BEGIN {OFS="\t"}{if(NR>=2) {print $1,$3,$4}}' > chr${id_chr}.fa.tmp
awk '{if($3=="a") {$3="A";print $0} else if($3=="t") {$3="T";print $0} else if($3=="c") {$3="C";print $0} else if($3=="g") {$3="G";print $0} else {print $0}}' chr${id_chr}.fa.tmp > chr${id_chr}.fa.tmp2
perl -pe 's/ +/\t/g' chr${id_chr}.fa.tmp2 > chr${id_chr}.reference_alleles
rm chr${id_chr}.bed chr${id_chr}.fa.out chr${id_chr}.fa.tmp chr${id_chr}.fa.tmp2

paste <(awk '{print $2}' tmp_chr${id_chr} ) <(awk 'BEGIN {FS="\t"}; {print $3}' chr${id_chr}.reference_alleles ) > chr${id_chr}_ref.txt

#### find variants to remove based on MAF and INFO
Rscript Find_var_toremove_MAF_INFO_run.R --chr chr${id_chr} --path_gen ${path} --path_info /ziller/laura/eQTL/DATA/ --outf ${path}

# use plink to correct wrong ref/alt annotations
/psycl/g/mpsziller/lucia/Software/software_slurmgate/PLINK2/plink2 --gen /ziller/laura/eQTL/F_DATA/FINAL_FILTERED_SNPS/filtered_chr${id_chr}_snps.gen --sample /ziller/laura/eQTL/F_DATA/CMC_MSSM-Penn-Pitt_DLPFC_DNA_imputed.sample --ref-allele force chr${id_chr}_ref.txt 2 1 --recode oxford ref-first  --exclude var_toremove_chr${id_chr} --out filtered_chr${id_chr}_corRefAlt_snps

rm chr${id_chr}.reference_alleles tmp_chr${id_chr}

