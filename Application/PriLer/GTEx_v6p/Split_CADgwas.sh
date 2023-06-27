#!/usr/bin/sh

cd /mnt/lucia/datasets/CAD_GWAS/

# chr1
awk  ' index($2,"1") && ! index($2,"10") && ! index($2,"11") && ! index($2,"12") && ! index($2,"13") && ! index($2,"14") && ! index($2,"15") && ! index($2,"16") && ! index($2,"17") && ! index($2,"18") && ! index($2,"19") && ! index($2,"21") ' cad.add.160614.website.txt > cad.add.160614.website_chr1.txt

# chr2
awk  ' index($2,"2") && ! index($2,"20") && ! index($2,"21") && ! index($2,"22") && ! index($2,"12") ' cad.add.160614.website.txt > cad.add.160614.website_chr2.txt

# chr3
awk  ' index($2,"3") && ! index($2,"13") ' cad.add.160614.website.txt > cad.add.160614.website_chr3.txt
# chr4
awk  ' index($2,"4") && ! index($2,"14") ' cad.add.160614.website.txt > cad.add.160614.website_chr4.txt
# chr5
awk  ' index($2,"5") && ! index($2,"15") ' cad.add.160614.website.txt > cad.add.160614.website_chr5.txt
# chr6
awk  ' index($2,"6") && ! index($2,"16") ' cad.add.160614.website.txt > cad.add.160614.website_chr6.txt
# chr7
awk  ' index($2,"7") && ! index($2,"17") ' cad.add.160614.website.txt > cad.add.160614.website_chr7.txt
# chr8
awk  ' index($2,"8") && ! index($2,"18") ' cad.add.160614.website.txt > cad.add.160614.website_chr8.txt
# chr9
awk  ' index($2,"9") && ! index($2,"19") ' cad.add.160614.website.txt > cad.add.160614.website_chr9.txt


for i in $(seq 10 1 22)
do
	chr=${i}
	echo ${chr}
	awk -v a="$chr" ' index($2,a) ' cad.add.160614.website.txt > cad.add.160614.website_chr${chr}.txt 
done

