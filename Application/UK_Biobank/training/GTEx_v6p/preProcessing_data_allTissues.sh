#!/usr/bin/sh

tissues=$(awk '{print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchUKBB/Tissue_noGWAS) # FNR>1 skip the first line
f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/

for t in ${tissues[@]}
do
	echo $t
	
	mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}
	mkdir /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchUKBB/RNAseq_data/${t}/
	
	${git_fold}Software/model_training/preProcessing_data_run.R --geneExp_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/RNAseq_norm.txt.gz --geneList_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v7/list_heritableGenes_${t}.txt --VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchUKBB/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-UKBB_ --biomartGenePos_file /psycl/g/mpsziller/lucia/refData/hg19.ENSEMBL_genes_biomart.txt --biomartTSS_file /psycl/g/mpsziller/lucia/refData/hg19.ENSEMBL_geneTSS_biomart_correct.txt --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/${t}/ --outFold_snps /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/ --outFold_geneExp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchUKBB/RNAseq_data/${t}/ 

done


