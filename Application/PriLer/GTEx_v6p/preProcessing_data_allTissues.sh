#!/usr/bin/sh


f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/

tissues=$(awk 'FNR>1 {print $1}' ${f}PriLer_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/Tissues_Names.txt) # FNR>1 skip the first line

for t in ${tissues[@]}
do
	echo $t
	
	mkdir -p ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}

	${git_fold}Software/model_training/preProcessing_data_run.R \
		--geneExp_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/RNAseq_norm.txt.gz \
		--geneList_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v7/list_heritableGenes_${t}.txt \
		--VarInfo_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_ \
		--biomartGenePos_file ${git_fold}refData/hg19.ENSEMBL_genes_biomart.txt \
		--biomartTSS_file ${git_fold}refData/hg19.ENSEMBL_geneTSS_biomart_correct.txt \
		--outFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/${t}/ \
		--outFold_snps ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/ \
		--outFold_geneExp ${f}PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/ 

done


