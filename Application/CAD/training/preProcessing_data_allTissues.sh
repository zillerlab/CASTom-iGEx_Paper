#!/usr/bin/sh

f=/psycl/g/mpsziller/lucia/

tissues=$(awk '{print $1}' ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Tissue_CADgwas) # FNR>1 skip the first line
git_fold=${f}castom-igex/Software/model_training/

#for t in ${tissues[@]}
#do
t=Whole_Blood
echo $t
	
mkdir ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}
mkdir ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/
	
${git_fold}preProcessing_data_run.R \
    --geneExp_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/RNAseq_norm.txt.gz \
    --geneList_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v7/list_heritableGenes_${t}.txt \
    --VarInfo_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-CADall-UKBB_ \
    --biomartGenePos_file ${f}refData/hg19.ENSEMBL_genes_biomart.txt \
    --biomartTSS_file ${f}refData/hg19.ENSEMBL_geneTSS_biomart_correct.txt \
    --outFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/ \
    --outFold_snps ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/ \
    --outFold_geneExp ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/ 

#done


