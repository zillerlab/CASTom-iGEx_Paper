#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_cluster_%x_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_cluster_%x_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=30G
#SBATCH --cpus-per-task=1


R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
id_clt=$1
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
tissue_considered=$(eval echo "\${tissues[${id_t}-1]}")
tissue_cl=$(eval echo "\${tissues[${id_clt}-1]}")

echo "Data from ${tissue_considered}"
echo "Cluster from ${tissue_cl}"

fold_cl=OUTPUT_GTEx/predict_CAD/${tissue_cl}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/cluster_specific_PALAS/
fold=${fold_cl}/${tissue_considered}/

ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

# correct for covariates
${git_fold}pheno_association_combine_largeData_run.R \
    --names_file ClusterCasesVSControls \
	--tscoreFold ${fold}Association_tscore_res/ \
	--pathScoreFold_Reactome ${fold}/Association_reactome_res/ \
	--pathScoreFold_GO ${fold}Association_GO_res/ \
	--outFold ${fold} \
	--cov_corr T \
	--phenoAnn_file ${fold_cl}phenotypeDescription_clusterSpecific.txt \
	--reactome_file ${ref_fold}ReactomePathways.gmt \
	--GOterms_file ${ref_fold}GOterm_geneAnnotation_allOntologies.RData



