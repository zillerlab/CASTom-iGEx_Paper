#!/usr/bin/sh


##############################
### intersect GRE and SNPs ###
##############################

f=/psycl/g/mpsziller/lucia/

Rscript Compute_SNP-GRE-mat_allChr_run.R \
    --outFold ${f}PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_CAD_UKBB/ \
    --VarInfo_file ${f}PriLer_PROJECT_GTEx/INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-CADall-UKBB_ \
    --peak_files ${f}datasets_denbi/FinalIDR_FPC_neuronal_ATAC_R2_macs2.bed ${f}datasets_denbi/FinalIDR_FPC_neuronal_ATAC_R4_macs2.bed ${f}datasets_denbi/hg19_Ctrl_150_allPeaks_cellRanger.bed ${f}datasets_denbi/hg19.CAD_paper_peak_H3K27ac_ATAC_merged.bed \
    --names_peak FPC_neuronal_ATAC_R2 FPC_neuronal_ATAC_R4 Ctrl_150_allPeaks_cellRanger CAD_H3K27ac_ATAC_merged \
    --perc_thr 0.4 \
    --GRElib_file ${f}datasets/hg19.1.H3K27ac_GRElibrary_v2_rpkm_quantile_95th_binary.txt 

 
