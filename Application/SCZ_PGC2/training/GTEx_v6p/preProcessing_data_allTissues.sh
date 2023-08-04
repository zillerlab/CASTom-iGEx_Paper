#!/usr/bin/sh

tissues=$(awk '{print $1}' /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/Tissue_PGCgwas_v2) # FNR>1 skip the first line
f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/

for t in ${tissues[@]}
do
	echo $t
	
	mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}
	mkdir -p /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/RNAseq_data/${t}/
	
	${git_fold}Software/model_training/preProcessing_data_run.R \
		--geneExp_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/RNAseq_norm.txt.gz \
		--geneList_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v7/list_heritableGenes_${t}.txt \
		--VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/Genotype_data/Genotype_VariantsInfo_maf001_info06_GTEx-PGCgwas-SCZ-PGCall_ \
		--biomartGenePos_file ${git_fold}refData/hg19.ENSEMBL_genes_biomart.txt \
		--biomartTSS_file ${git_fold}refData/hg19.ENSEMBL_geneTSS_biomart_correct.txt \
		--outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/${t}/ \
		--outFold_snps /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/ \
		--outFold_geneExp /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/RNAseq_data/${t}/ 

done


