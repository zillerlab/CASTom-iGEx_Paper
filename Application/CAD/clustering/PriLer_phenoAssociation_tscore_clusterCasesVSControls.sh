#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_cluster_tscore_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_cluster_tscore_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=5

R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

id_t=$1
id_clt=$2
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
tissue_considered=$(eval echo "\${tissues[${id_t}-1]}")
tissue_cl=$(eval echo "\${tissues[${id_clt}-1]}")

echo "Data from ${tissue_considered}"
echo "Cluster from ${tissue_cl}"
echo "Split gene ${SLURM_ARRAY_TASK_ID}"

mkdir -p OUTPUT_GTEx/predict_CAD/${tissue_cl}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/cluster_specific_PALAS/${tissue_considered}/Association_tscore_res/
fold_data=OUTPUT_GTEx/predict_CAD/${tissue_considered}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
fold_cl=OUTPUT_GTEx/predict_CAD/${tissue_cl}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/cluster_specific_PALAS/

# correct for covariates
${git_fold}pheno_association_tscore_largeData_run.R \
	--split_tot 100 \
	--inputInfoFile ${fold_data}tscore_info.RData \
	--covDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW_202304.txt \
	--phenoDat_file ${fold_cl}phenoMatrix_clusterSpecific.txt \
	--names_file ClusterCasesVSControls \
	--inputFile ${fold_data}predictedTscores_splitGenes${SLURM_ARRAY_TASK_ID}.RData \
	--outFile ${fold_cl}/${tissue_considered}/Association_tscore_res/pval_tscore_splitGene${SLURM_ARRAY_TASK_ID}_ \
	--split_gene_id ${SLURM_ARRAY_TASK_ID} \
	--cov_corr T \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW_202304.txt \
	--ncores 5 \
	--phenoAnn_file ${fold_cl}phenotypeDescription_clusterSpecific.txt \
	--functR ${git_fold}pheno_association_functions.R  

