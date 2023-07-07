#!/bin/bash
#SBATCH --job-name=epi
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/SNP-GRE_ann_allchr_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/SNP-GRE_ann_allchr_%j.err
#SBATCH --mem-per-cpu=20G
#SBATCH -c 1
#SBATCH -p pe

ref_castom_git=/psycl/g/mpsziller/lucia/castom-igex/refData/prior_features/

Rscript Compute_SNP-GRE-mat_allChr_run.R \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/ \
    --VarInfo_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/Genotype_VariantsInfo_CMC-PGC_ \
    --peak_files ${ref_castom_git}FinalIDR_FPC_neuronal_ATAC_R2_macs2.bed ${ref_castom_git}FinalIDR_FPC_neuronal_ATAC_R4_macs2.bed ${ref_castom_git}hg19_Ctrl_150_allPeaks_cellRanger.bed  \
    --GRElib_file ${ref_castom_git}hg19.1.H3K27ac_GRElibrary_v2_rpkm_quantile_95th_binary.txt \
    --names_peak FPC_neuronal_ATAC_R2 FPC_neuronal_ATAC_R4 Ctrl_150_allPeaks_cellRanger \
    --perc_thr 0.4



