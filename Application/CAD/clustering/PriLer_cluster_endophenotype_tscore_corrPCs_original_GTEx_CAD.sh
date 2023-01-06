#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_original_corrPCs_pheno_CAD_t%a_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_original_corrPCs_pheno_CAD_t%a_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=20G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
fold_input=INPUT_DATA_GTEx/CAD/Covariates/UKBB/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/


#### PHESANT phenotypes ####
# rescale continuous phenotypes
# correct for medications
${git_fold}cluster_associatePhenoGLM_run.R \
	--sampleAnnFile ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoDatFile ${cov_fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoDescFile ${cov_fold}phenotypeDescription_withMedication.txt \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold}rescaleCont_withMedication_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input corrPCs_original \
	--type_sim HK \
	--clusterFile ${fold}tscore_corrPCs_original_clusterCases_PGmethod_HKmetric.RData \
	--rescale_pheno T

# comormidities, do not correct for medications
${git_fold}cluster_associatePhenoGLM_run.R \
	--sampleAnnFile ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc.txt \
	--phenoDatFile ${cov_fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withoutMedication.txt \
	--phenoDescFile ${cov_fold}phenotypeDescription_withoutMedication.txt \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold}rescaleCont_withoutMedication_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input corrPCs_original \
	--type_sim HK \
	--clusterFile ${fold}tscore_corrPCs_original_clusterCases_PGmethod_HKmetric.RData \
	--rescale_pheno T

# plot and combined 
${git_fold_plot}plot_endophenotype_grVSall_run.R \
	--type_cluster_data tscore \
        --type_cluster Cases \
	--type_input corrPCs_original \
	--endopFile ${fold}rescaleCont_withMedication_tscore_corrPCs_original_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData ${fold}rescaleCont_withoutMedication_tscore_corrPCs_original_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData \
	--outFold ${fold} \
	--forest_plot T \
	--pval_pheno 0.001 \
	--colorFile INPUT_DATA_GTEx/CAD/Covariates/UKBB/color_pheno_type_UKBB.txt



