#!/bin/bash
#SBATCH --job-name=pheno
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_DLPC_SCZ-PGC.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_DLPC_SCZ-PGC.err
#SBATCH --mem=10G
#SBATCH -c 1
#SBATCH -p hp


fold=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/predict_All/DLPC_CMC/devgeno0.01_testdevgeno0/

Rscript ./compare_discovery_replication_SCZ.R \
    --tissues_name DLPC_CMC \
    --discovery_res /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/Meta_Analysis_SCZ/DLPC_CMC/pval_Dx_pheno_covCorr.RData \
    --replication_res ${fold}pval_Dx_covCorr.RData \
    --outFold ${fold} \
    --color_file /psycl/g/mpsziller/lucia/castom-igex/refData/color_tissues.txt \
    --pheno_name $1
