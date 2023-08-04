#!/usr/bin/sh


##############################
### intersect GRE and SNPs ###
##############################

git_fold=/psycl/g/mpsziller/lucia/castom-igex/

Rscript ./Compute_SNP-GRE-mat_allChr_run.R \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/ \
    --VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/Genotype_data/Genotype_VariantsInfo_maf001_info06_GTEx-PGCgwas-SCZ-PGCall_ \
    --peak_files ${git_fold}/refData/prior_features/FinalIDR_FPC_neuronal_ATAC_R2_macs2.bed ${git_fold}/refData/prior_features/FinalIDR_FPC_neuronal_ATAC_R4_macs2.bed ${git_fold}/refData/prior_features/hg19_Ctrl_150_allPeaks_cellRanger.bed ${git_fold}/refData/prior_features/hg19.CAD_paper_peak_H3K27ac_ATAC_merged.bed \
    --names_peak FPC_neuronal_ATAC_R2 FPC_neuronal_ATAC_R4 Ctrl_150_allPeaks_cellRanger CAD_H3K27ac_ATAC_merged \
    --perc_thr 0.4 \
    --GRElib_file ${git_fold}/refData/hg19.1.H3K27ac_GRElibrary_v2_rpkm_quantile_95th_binary.txt 

 
