#!/bin/bash

tissues=$(awk '{print $1}' /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Tissue_CADgwas) # FNR>1 skip the first line

# save header of prior matrix, convert to a column and add index
zcat /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/priorMatrix_chr1.txt.gz | head -1 |  grep -oP '\S+' | cat -n > /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/allPriorName.txt

for t in ${tissues[@]}
do
	echo $t
	
	# from the association file, find row of tissue of interest, convert to tab separeted and to a colum
	readarray -t t_CAD < <(cut -d, -f1 /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_CADgwas.csv)
        if [[ " ${t_CAD[@]} " =~ " ${t} " ]]
       	then	
		
		mkdir -p /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2/
		# from the association file, find row of tissue of interest, convert to tab separeted and to a colum
        	awk -F "," -v a="$t" '$1==a' /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_CADgwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas.txt
	
		# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        	awk 'NR==FNR{_[$1];next}($2 in _)'  /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas.txt  /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/allPriorName.txt > /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas_withIndex.txt
        	rm /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CADgwas.txt

	fi
done
