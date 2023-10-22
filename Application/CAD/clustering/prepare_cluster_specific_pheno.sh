#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/prepare_cluster_specific_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/prepare_cluster_specific_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=4G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/

fold_script=/psycl/g/mpsziller/lucia/castom_cad_scz/Application/CAD/clustering/
Rscript ${fold_script}prepare_cluster_specific_pheno.R \
    --clusterFile ${fold}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
    --sampleAnnFile ${cov_fold}covariateMatrix_latestW_202304.txt \
    --phenoDatFile_CADHARD ${cov_fold}phenoMatrix.txt \
    --outFold ${fold}cluster_specific_PALAS/