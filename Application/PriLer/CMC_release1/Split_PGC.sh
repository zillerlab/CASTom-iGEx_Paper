#!/bin/bash
#SBATCH --job-name=conv
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/pgc_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/pgc_%j.err
#SBATCH --mem-per-cpu=5G
#SBATCH -c 1
#SBATCH -p hp

fold=/psycl/g/mpsziller/lucia/refData/SCZ_GWAS/

# chr1
awk  ' index($1,"chr1") && ! index($1,"chr10") && ! index($1,"chr11") && ! index($1,"chr12") && ! index($1,"chr13") && ! index($1,"chr14") && ! index($1,"chr15") && ! index($1,"chr16") && ! index($1,"chr17") && ! index($1,"chr18") && ! index($1,"chr19") ' ${fold}Original_SCZ_variants_PGC.txt > ${fold}Original_SCZ_variants_chr1.txt

# chr2
awk  ' index($1,"chr2") && ! index($1,"chr20") && ! index($1,"chr21") && ! index($1,"chr22") ' ${fold}Original_SCZ_variants_PGC.txt > ${fold}Original_SCZ_variants_chr2.txt


for i in $(seq 3 1 22)
do
	chr=chr${i}
	echo ${chr}
	awk -v a="$chr" ' index($1,a) ' ${fold}Original_SCZ_variants_PGC.txt > ${fold}Original_SCZ_variants_${chr}.txt 
done


