#!/bin/bash

cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/

# save header of prior matrix, convert to a column and add index
zcat priorMatrix_random_Ctrl_150_allPeaks_allRanger_heart_left_ventricle_GWAS_withRep_chr1.txt.gz | head -1 |  grep -oP '\S+' | cat -n > allPriorName_randomPrior.txt


#####################
#### random GWAS ####
#####################

nrep_gwas=10

for r in $(seq 1 ${nrep_gwas})
do
	
	# Brain Cortex
	type_gwas_PGC=(PVAL_PGC_random_lE_r${r} PVAL_PGC_random_mE_r${r} PVAL_PGC_random_hE_r${r})
	mkdir -p Brain_Cortex/200kb/PGC_GWAS_bin1e-2_randomGWAS/rep${r}/
	awk -F "," -v a="Brain_Cortex" '$1==a' ../INPUT_DATA/prior_association_PGCgwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > Brain_Cortex/priorName_PGCgwas.txt
	for i in ${type_gwas_PGC[@]}; do echo ${i} >> Brain_Cortex/priorName_PGCgwas.txt ; done
	# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        awk 'NR==FNR{_[$1];next}($2 in _)'  Brain_Cortex/priorName_PGCgwas.txt  allPriorName_randomPrior.txt > Brain_Cortex/200kb/PGC_GWAS_bin1e-2_randomGWAS/rep${r}/priorName_PGCgwas_withIndex.txt
        rm Brain_Cortex/priorName_PGCgwas.txt
	
	# Artery Coronary
	type_gwas_CAD=(PVAL_CAD_random_lE_r${r} PVAL_CAD_random_mE_r${r} PVAL_CAD_random_hE_r${r})
	mkdir -p Artery_Coronary/200kb/CAD_GWAS_bin5e-2_randomGWAS/rep${r}/		
	awk -F "," -v a="Artery_Coronary" '$1==a' ../INPUT_DATA/prior_association_CADgwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > Artery_Coronary/priorName_CADgwas.txt
	for i in ${type_gwas_CAD[@]}; do echo ${i} >> Artery_Coronary/priorName_CADgwas.txt ; done
	# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        awk 'NR==FNR{_[$1];next}($2 in _)'  Artery_Coronary/priorName_CADgwas.txt  allPriorName_randomPrior.txt > Artery_Coronary/200kb/CAD_GWAS_bin5e-2_randomGWAS/rep${r}/priorName_CADgwas_withIndex.txt
        rm Artery_Coronary/priorName_CADgwas.txt
		
done	

####################
#### random Var ####
####################

nrep_var=50
for r in $(seq 1 ${nrep_var})
do

	type_var_BC=(Ctrl_150_allPeaks_allRanger_Var_random_r${r} Ctrl_150_allPeaks_allRanger_Var_random2x_r${r})
	mkdir -p Brain_Cortex/200kb/PGC_GWAS_bin1e-2_randomVar/rep${r}/
	awk -F "," -v a="Brain_Cortex" '$1==a' ../INPUT_DATA/prior_association_PGCgwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > Brain_Cortex/priorName_PGCgwas.txt
	for i in ${type_var_BC[@]}; do echo ${i} >> Brain_Cortex/priorName_PGCgwas.txt ; done
	# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        awk 'NR==FNR{_[$1];next}($2 in _)'  Brain_Cortex/priorName_PGCgwas.txt  allPriorName_randomPrior.txt > Brain_Cortex/200kb/PGC_GWAS_bin1e-2_randomVar/rep${r}/priorName_PGCgwas_withIndex.txt
        rm Brain_Cortex/priorName_PGCgwas.txt

	type_var_AC=(heart_left_ventricle_Var_random_r${r} heart_left_ventricle_Var_random2x_r${r})
	mkdir -p Artery_Coronary/200kb/CAD_GWAS_bin5e-2_randomVar/rep${r}/
	awk -F "," -v a="Artery_Coronary" '$1==a' ../INPUT_DATA/prior_association_CADgwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > Artery_Coronary/priorName_CADgwas.txt
	for i in ${type_var_AC[@]}; do echo ${i} >> Artery_Coronary/priorName_CADgwas.txt ; done
	# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        awk 'NR==FNR{_[$1];next}($2 in _)'  Artery_Coronary/priorName_CADgwas.txt  allPriorName_randomPrior.txt > Artery_Coronary/200kb/CAD_GWAS_bin5e-2_randomVar/rep${r}/priorName_CADgwas_withIndex.txt
        rm Artery_Coronary/priorName_CADgwas.txt

done
	
####################
#### random Epi ####
####################

nrep_epi=50
for r in $(seq 1 ${nrep_epi})
do

	type_epi_BC=(Ctrl_150_allPeaks_allRanger_Epi_random_r${r} Ctrl_150_allPeaks_allRanger_Epi_random2x_r${r} Ctrl_150_allPeaks_allRanger_Epi_random_noint_r${r} heart_left_ventricle)
	mkdir -p Brain_Cortex/200kb/PGC_GWAS_bin1e-2_randomEpi/rep${r}/
	awk -F "," -v a="Brain_Cortex" '$1==a' ../INPUT_DATA/prior_association_PGCgwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > Brain_Cortex/priorName_PGCgwas.txt
	for i in ${type_epi_BC[@]}; do echo ${i} >> Brain_Cortex/priorName_PGCgwas.txt ; done
	# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        awk 'NR==FNR{_[$1];next}($2 in _)'  Brain_Cortex/priorName_PGCgwas.txt  allPriorName_randomPrior.txt > Brain_Cortex/200kb/PGC_GWAS_bin1e-2_randomEpi/rep${r}/priorName_PGCgwas_withIndex.txt
        rm Brain_Cortex/priorName_PGCgwas.txt

	type_epi_AC=(heart_left_ventricle_Epi_random_r${r} heart_left_ventricle_Epi_random2x_r${r} heart_left_ventricle_Epi_random_noint_r${r} Ctrl_150_allPeaks_cellRanger)
	mkdir -p Artery_Coronary/200kb/CAD_GWAS_bin5e-2_randomEpi/rep${r}/
	awk -F "," -v a="Artery_Coronary" '$1==a' ../INPUT_DATA/prior_association_CADgwas.csv | sed -r -e 's/("([^"]*)")?,/\2\t/g' | grep -oP '\S+' > Artery_Coronary/priorName_CADgwas.txt
	for i in ${type_epi_AC[@]}; do echo ${i} >> Artery_Coronary/priorName_CADgwas.txt ; done
	# keep only line of allPriorName.txt in the tissues specific priorName.txt file
        awk 'NR==FNR{_[$1];next}($2 in _)'  Artery_Coronary/priorName_CADgwas.txt  allPriorName_randomPrior.txt > Artery_Coronary/200kb/CAD_GWAS_bin5e-2_randomEpi/rep${r}/priorName_CADgwas_withIndex.txt
        rm Artery_Coronary/priorName_CADgwas.txt

done
	
	

