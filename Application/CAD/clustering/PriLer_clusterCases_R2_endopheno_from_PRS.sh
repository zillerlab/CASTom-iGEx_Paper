#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_PRS_%x_R2_CAD.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_PRS_%x_R2_CAD.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

fold=OUTPUT_GWAS/PRS/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
fold_input=INPUT_DATA_GTEx/CAD/Covariates/UKBB/
script_fold=/psycl/g/mpsziller/lucia/castom_cad_scz/Application/CAD/clustering/
name=$1

#### rescale continuous phenotypes
# correct for medications
Rscript ${script_fold}compare_R2_endopheno_from_groups.R \
    --cluster_file ${fold}PRS_CAD_UKBB_Cases_${name}.RData \
    --PRS_file ${fold}PRS_CAD_UKBB.best \
	--sampleAnn_file ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--pheno_file ${cov_fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoAnn_file ${cov_fold}phenotypeDescription_withMedication.txt \
	--outFold ${fold}rescaleCont_withMedication_PRS_${name}_clusterCases_ 

# associate with comobordities
Rscript ${script_fold}compare_R2_endopheno_from_groups.R \
    --cluster_file ${fold}PRS_CAD_UKBB_Cases_${name}.RData \
    --PRS_file ${fold}PRS_CAD_UKBB.best \
	--sampleAnn_file ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc.txt \
	--pheno_file ${cov_fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withoutMedication.txt \
	--phenoAnn_file ${cov_fold}phenotypeDescription_withoutMedication.txt \
	--outFold ${fold}rescaleCont_withoutMedication_PRS_${name}_clusterCases_ 