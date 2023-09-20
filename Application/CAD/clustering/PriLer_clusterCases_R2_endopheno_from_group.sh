#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_R2_CAD_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_R2_CAD_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
fold_input=INPUT_DATA_GTEx/CAD/Covariates/UKBB/
script_fold=/psycl/g/mpsziller/lucia/castom_cad_scz/Application/CAD/clustering/

#### rescale continuous phenotypes
# correct for medications
Rscript ${script_fold}compare_R2_endopheno_from_groups.R \
    --cluster_file ${fold}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--sampleAnn_file ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--pheno_file ${cov_fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoAnn_file ${cov_fold}phenotypeDescription_withMedication.txt \
	--outFold ${fold}rescaleCont_withMedication_tscore_corrPCs_zscaled_clusterCases_ 

# associate with comobordities
Rscript ${script_fold}compare_R2_endopheno_from_groups.R \
    --cluster_file ${fold}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--sampleAnn_file ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc.txt \
	--pheno_file ${cov_fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withoutMedication.txt \
	--phenoAnn_file ${cov_fold}phenotypeDescription_withoutMedication.txt \
	--outFold ${fold}rescaleCont_withoutMedication_tscore_corrPCs_zscaled_clusterCases_ 