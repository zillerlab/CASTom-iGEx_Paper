#!/bin/bash
#SBATCH --job-name=epi
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/SNP-GRE_ann_allchr_SCZ-PGC_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/SNP-GRE_ann_allchr_SCZ-PGC_%j.err
#SBATCH --mem-per-cpu=20G
#SBATCH -c 1
#SBATCH -p gpu


Rscript ./Compute_SNP-GRE-mat_allChr_run.R \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/ \
    --VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/Genotype_VariantsInfo_maf001_info06_CMC-PGCgwas-SCZ-PGCall_ \
    --peak_files /ziller/Michael/All_PeakFiles/FinalIDR_FPC_neuronal_ATAC_R2_macs2.bed /ziller/Michael/All_PeakFiles/FinalIDR_FPC_neuronal_ATAC_R4_macs2.bed /ziller/lucia/datasets/hg19_Ctrl_150_allPeaks_cellRanger.bed  \
    --GRElib_file /ziller/GRE_library/H3K27ac_v2/hg19.1.H3K27ac_GRElibrary_v2_rpkm_quantile_95th_binary.txt --names_peak FPC_neuronal_ATAC_R2 FPC_neuronal_ATAC_R4 Ctrl_150_allPeaks_cellRanger \
    --perc_thr 0.4



