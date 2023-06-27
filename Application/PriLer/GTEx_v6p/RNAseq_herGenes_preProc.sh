#!/usr/bin/sh


#######################################
### extract list of genes from TWAS ###
#######################################

#tissues=$(awk 'FNR>1 {print $1}' /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/Tissues_Names.txt) # FNR>1 skip the first line
#
#cd /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v7/
#
#for t in ${tissues[@]}
#do
#	echo $t
#	
#	wget 'http://gusevlab.org/projects/fusion/weights/GTEx.'$t'.P01.tar.bz2'
#	bzip2 -d 'GTEx.'$t'.P01.tar.bz2'
#	tar -xvf 'GTEx.'$t'.P01.tar' $t'.hsq'
#	tar -xvf 'GTEx.'$t'.P01.tar' $t'.P01.pos'
#	# rm 'GTEx.'$t'.P01.tar' # needed for the evaluation!
#
#done

#for t in ${tissues[@]}
#do
#	echo $t
#	awk 'FNR>1 {print $3,$4,$5,$6}' OFS='\t' $t'.P01.pos' > tmp
#	{ printf 'external_gene_name\tchrom\tstart_position\tend_position\n'; cat tmp; } > list_heritableGenes_${t}.txt
#
#done



############################################################
### preprocess RNA for each tissue, normalize, find PEER ### 
############################################################

#cd /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/

#for t in ${tissues[@]}
#do
#	echo $t
#	
#	mkdir RNAseq_data/${t}
#	
#
#done


Rscript /mnt/lucia/eQTL_PROJECT_GTEx/RSCRIPTS/RNAseq_normalizationPerTissue.R
