#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_PCs_pheno_CAD_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_PCs_pheno_CAD_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=20G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/
fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/

#### rescale continuous phenotypes
${git_fold}cluster_associatePhenoGLM_run.R \
	--sampleAnnFile ${fold}covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoDatFile ${fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoDescFile ${fold}phenotypeDescription_withMedication.txt \
	--type_data PCs \
	--type_cluster $1 \
	--outFold ${fold}rescaleCont_withMedication_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input original \
	--type_sim HK \
	--clusterFile ${fold}PCs_cluster$1_PGmethod_HKmetric.RData \
	--rescale_pheno T

${git_fold}cluster_associatePhenoGLM_run.R \
	--sampleAnnFile ${fold}covariateMatrix_CADHARD_All_phenoAssoc.txt  \
	--phenoDatFile ${fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withoutMedication.txt \
	--phenoDescFile ${fold}phenotypeDescription_withoutMedication.txt \
	--type_data PCs \
	--type_cluster $1 \
	--outFold ${fold}rescaleCont_withoutMedication_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input original \
	--type_sim HK \
	--clusterFile ${fold}PCs_cluster$1_PGmethod_HKmetric.RData \
	--rescale_pheno T

# plot and combined 
${git_fold}plot_endophenotype_grVSall_run.R \
	--type_cluster_data PCs \
    --type_cluster $1 \
	--type_input original \
	--forest_plot TRUE \
	--endopFile ${fold}rescaleCont_withMedication_PCs_original_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData ${fold}rescaleCont_withoutMedication_PCs_original_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData \
	--outFold ${fold} \
	--colorFile ${ref_fold}color_pheno_type_UKBB.txt

