#!/bin/bash

tissues=$(awk '{print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/Tissues_1col_red) # FNR>1 skip the first line

# save header of prior matrix, convert to a column and add index
zcat /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/priorMatrix_chr1.txt.gz | head -1 |  grep -oP '\S+' | cat -n > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName.txt
zcat /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/priorMatrix_random_Ctrl_150_allPeaks_allRanger_heart_left_ventricle_GWAS_chr1.txt.gz | head -1 |  grep -oP '\S+' | cat -n > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName_randomPrior.txt

for t in ${tissues[@]}
do
	echo $t
	
	# from the association file, find row of tissue of interest, convert to tab separeted and to a colum
	readarray -t t_nog < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_nogwas.csv)	
 	if [[ " ${t_nog[@]} " =~ " ${t} " ]] 
	then	
		mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/noGWAS/
        	awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_nogwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_nogwas.txt

        	# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        	awk 'NR==FNR{_[$1];next}($2 in _)'  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_nogwas.txt  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_nogwas_withIndex.txt
        	rm /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_nogwas.txt
	fi
	
	readarray -t t_CAD < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_CADgwas.csv)
        if [[ " ${t_CAD[@]} " =~ " ${t} " ]]
       	then	
		
		mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin5e-2/
		# from the association file, find row of tissue of interest, convert to tab separeted and to a colum
        	awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_CADgwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas.txt
	
		# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        	awk 'NR==FNR{_[$1];next}($2 in _)'  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas.txt  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_withIndex.txt
        	rm /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas.txt

	fi
	
	readarray -t t_PGC < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_PGCgwas.csv)
        if [[ " ${t_PGC[@]} " =~ " ${t} " ]]
	then 
		mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2/
		# from the association file, find row of tissue of interest, convert to tab separeted and to a colum
		awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_PGCgwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas.txt
	
		# keep only line of allPriorName.txt in the tissues specific priorName.txt file
		awk 'NR==FNR{_[$1];next}($2 in _)'  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas.txt  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_withIndex.txt
		rm /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas.txt
	fi

	# randomGWAS, PGC
	readarray -t t_rG_PGC < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_PGCgwas_rG.csv)
	if [[ " ${t_rG_PGC[@]} " =~ " ${t} " ]]
	then
		mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2_randomGWAS/
		awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_PGCgwas_rG.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomGWAS.txt
		awk 'NR==FNR{_[$1];next}($2 in _)'  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomGWAS.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName_randomPrior.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomGWAS_withIndex.txt
		rm /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomGWAS.txt
	fi

	# randomGWAS, CAD
	readarray -t t_rG_CAD < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_CADgwas_rG.csv)
	if [[ " ${t_rG_CAD[@]} " =~ " ${t} " ]]
	then
		mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin5e-2_randomGWAS/
		awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_CADgwas_rG.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomGWAS.txt
		awk 'NR==FNR{_[$1];next}($2 in _)'  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomGWAS.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName_randomPrior.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomGWAS_withIndex.txt
		rm /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomGWAS.txt
	fi
	
	# randomVar, PGC
	readarray -t t_rV_PGC < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_PGCgwas_rV.csv)
	if [[ " ${t_rV_PGC[@]} " =~ " ${t} " ]]
	then
		mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2_randomVar/
		awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_PGCgwas_rV.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomVar.txt
		awk 'NR==FNR{_[$1];next}($2 in _)'  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomVar.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName_randomPrior.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomVar_withIndex.txt
		rm /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomVar.txt
	fi

	# randomVar, CAD
	readarray -t t_rV_CAD < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_CADgwas_rV.csv)
	if [[ " ${t_rV_CAD[@]} " =~ " ${t} " ]]
	then
		mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin5e-2_randomVar/
		awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_CADgwas_rV.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomVar.txt
		awk 'NR==FNR{_[$1];next}($2 in _)'  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomVar.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName_randomPrior.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomVar_withIndex.txt
		rm /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomVar.txt
	fi
	
	# randomEpi, PGC
	readarray -t t_rE_PGC < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_PGCgwas_rE.csv)
	if [[ " ${t_rE_PGC[@]} " =~ " ${t} " ]]
	then
		mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin1e-2_randomEpi/
		awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_PGCgwas_rE.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomEpi.txt
		awk 'NR==FNR{_[$1];next}($2 in _)'  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomEpi.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName_randomPrior.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomEpi_withIndex.txt
		rm /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_PGCgwas_randomEpi.txt
	fi

	# randomEpi, CAD
	readarray -t t_rE_CAD < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_CADgwas_rE.csv)
	if [[ " ${t_rE_CAD[@]} " =~ " ${t} " ]]
	then
		mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin5e-2_randomEpi/
		awk -F "," -v a="$t" '$1==a' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prior_association_CADgwas_rE.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomEpi.txt
		awk 'NR==FNR{_[$1];next}($2 in _)'  /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomEpi.txt /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/allPriorName_randomPrior.txt > /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomEpi_withIndex.txt
		rm /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/priorName_CADgwas_randomEpi.txt
	fi
	
	
done

