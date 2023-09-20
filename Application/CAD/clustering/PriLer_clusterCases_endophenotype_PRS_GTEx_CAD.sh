#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/PRS_%x_pheno_CAD.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/PRS_%x_pheno_CAD.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
name=$1

fold=OUTPUT_GWAS/PRS/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
fold_input=INPUT_DATA_GTEx/CAD/Covariates/UKBB/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/

#### rescale continuous phenotypes
# correct for medications
${git_fold}cluster_associatePhenoGLM_run.R \
	--sampleAnnFile ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoDatFile ${cov_fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoDescFile ${cov_fold}phenotypeDescription_withMedication.txt \
	--type_data PRS \
	--type_cluster Cases \
	--outFold ${fold}rescaleCont_withMedication_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input ${name} \
	--type_sim none \
	--clusterFile ${fold}PRS_CAD_UKBB_Cases_${name}.RData \
	--rescale_pheno T

# associate with comobordities
${git_fold}cluster_associatePhenoGLM_run.R \
	--sampleAnnFile ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc.txt \
	--phenoDatFile ${cov_fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withoutMedication.txt \
	--phenoDescFile ${cov_fold}phenotypeDescription_withoutMedication.txt \
	--type_data PRS \
	--type_cluster Cases \
	--outFold ${fold}rescaleCont_withoutMedication_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input ${name} \
	--type_sim none \
	--clusterFile ${fold}PRS_CAD_UKBB_Cases_${name}.RData \
	--rescale_pheno T

# plot and combined 
${git_fold}plot_endophenotype_grVSall_run.R \
	--type_cluster_data PRS \
    --type_cluster Cases \
	--type_input ${name} \
	--endopFile ${fold}rescaleCont_withMedication_PRS_${name}_clusterCases_PGmethod_nonemetric_phenoAssociation_GLM.RData ${fold}rescaleCont_withoutMedication_PRS_${name}_clusterCases_PGmethod_nonemetric_phenoAssociation_GLM.RData \
	--outFold ${fold} \
	--forest_plot T \
	--pval_pheno 0.001 \
	--colorFile ${ref_fold}color_pheno_type_UKBB.txt




