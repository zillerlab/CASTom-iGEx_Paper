#!/usr/bin/sh


##############################
### intersect GRE and SNPs ###
##############################

Rscript /mnt/lucia/eQTL_PROJECT_GTEx/RSCRIPTS/Compute_SNP-GRE-mat_allChr_run.R --outFold /mnt/lucia/eQTL_PROJECT_GTEx/OUTPUT/  --VarInfo_file /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_  --peak_files /mnt/lucia/datasets/FinalIDR_FPC_neuronal_ATAC_R2_macs2.bed /mnt/lucia/datasets/FinalIDR_FPC_neuronal_ATAC_R4_macs2.bed /mnt/lucia/datasets/hg19_Ctrl_150_allPeaks_cellRanger.bed /mnt/lucia/datasets/hg19.CAD_paper_peak_H3K27ac_ATAC_merged.bed --names_peak FPC_neuronal_ATAC_R2 FPC_neuronal_ATAC_R4 Ctrl_150_allPeaks_cellRanger CAD_H3K27ac_ATAC_merged --perc_thr 0.4  --GRElib_file /mnt/lucia/datasets/hg19.1.H3K27ac_GRElibrary_v2_rpkm_quantile_95th_binary.txt 

 
