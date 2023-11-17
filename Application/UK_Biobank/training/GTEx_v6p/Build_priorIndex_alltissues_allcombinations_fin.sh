#!/bin/bash

f=/psycl/g/mpsziller/lucia/
tissues=$(awk '{print $1}' ${f}PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/Tissues_1col_red) # FNR>1 skip the first line

# save header of prior matrix, convert to a column and add index
zcat ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/priorMatrix_chr1.txt.gz | head -1 |  grep -oP '\S+' | cat -n > ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/allPriorName.txt

for t in ${tissues[@]}
do
	echo $t
	
	# from the association file, find row of tissue of interest, convert to tab separeted and to a colum
	readarray -t t_nog < <(cut -d, -f1 ${f}PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_nogwas.csv)	
 	if [[ " ${t_nog[@]} " =~ " ${t} " ]] 
	then	
		mkdir ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/200kb/noGWAS/
        	awk -F "," -v a="$t" '$1==a' ${f}PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_nogwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/priorName_nogwas.txt

        	# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        	awk 'NR==FNR{_[$1];next}($2 in _)'  ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/priorName_nogwas.txt  ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/allPriorName.txt > ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/priorName_nogwas_withIndex.txt
        	rm ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/priorName_nogwas.txt
	fi
	
done

