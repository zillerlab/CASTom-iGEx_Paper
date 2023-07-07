#!/bin/bash
#SBATCH --job-name=ann
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/preProc_step_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/preProc_step_%j.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p hp

f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/

${git_fold}Software/model_training/preProcessing_data_run.R \
    --geneExp_file ${f}CMC_release1/CommonMind/SCZ/RNA-Seq_normalized/Gene/EXCLUDE\ ANCESTRY\ +\ SVA/CMC_MSSM-Penn-Pitt_DLPFC_mRNA_IlluminaHiSeq2500_gene-adjustedSVA-dataNormalization-noAncestry-adjustedLogCPM.tsv \
    --geneList_file ${f}PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/list_heritableGenes.txt \
    --VarInfo_file ${f}PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/Genotype_VariantsInfo_CMC-PGC_ \
    --biomartGenePos_file ${git_fold}refData/hg19.ENSEMBL_genes_biomart.txt \
    --biomartTSS_file ${git_fold}refData/hg19.ENSEMBL_geneTSS_biomart_correct.txt \
    --outFold ${f}PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/ \
    --outFold_geneExp ${f}PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/RNAseq_data/EXCLUDE_ANCESTRY_SVA/



