#!/usr/bin/sh

tissues=$(awk '{print $1}' /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Tissue_CADgwas) # FNR>1 skip the first line
git_fold=/mnt/lucia/castom-igex/Software/model_training/

#for t in ${tissues[@]}
#do
t=Whole_Blood
echo $t
	
mkdir /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}
mkdir /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/
	
Rscript ${git_fold}preProcessing_data_run.R --geneExp_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/RNAseq_data/${t}/RNAseq_norm.txt.gz --geneList_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v7/list_heritableGenes_${t}.txt --VarInfo_file /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-CADall-UKBB_ --biomartGenePos_file /mnt/lucia/refData/hg19.ENSEMBL_genes_biomart.txt --biomartTSS_file /mnt/lucia/refData/hg19.ENSEMBL_geneTSS_biomart_correct.txt --outFold /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/ --outFold_snps /mnt/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/ --outFold_geneExp /mnt/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/ 

#done


