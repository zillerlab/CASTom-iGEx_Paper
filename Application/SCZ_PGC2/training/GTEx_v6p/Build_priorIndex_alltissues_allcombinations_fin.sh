#!/bin/bash

tissues=$(awk '{print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/Tissues_1col_red) # FNR>1 skip the first line

# save header of prior matrix, convert to a column and add index
zcat /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/priorMatrix_chr1.txt.gz | head -1 |  grep -oP '\S+' | cat -n > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/allPriorName.txt

for t in ${tissues[@]}
do
	echo $t
	
	# from the association file, find row of tissue of interest, convert to tab separeted and to a colum
	readarray -t t_pgc < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_PGCgwas.csv)	
 	if [[ " ${t_pgc[@]} " =~ " ${t} " ]] 
	then	
		mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/200kb/PGC_GWAS_bin1e-2/
        	awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_PGCgwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/priorName_PGCgwas.txt

        	# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        	awk 'NR==FNR{_[$1];next}($2 in _)'  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/priorName_PGCgwas.txt  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/allPriorName.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/priorName_PGCgwas_withIndex.txt
        	rm /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/priorName_PGCgwas.txt
	fi
	
done

