#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_treatResponse_CAD_t11_randomREP%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_treatResponse_CAD_t11_randomREP%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id=${SLURM_ARRAY_TASK_ID}
t=Liver

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/random_cluster/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/


Rscript ${git_fold}cluster_treatmentResponseAnalysis_run.R \
	--covDatFile ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoDatFile ${cov_fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoDescFile ${cov_fold}phenotypeDescription_withMedication.txt \
	--phenoDescCovFile ${cov_fold}phenotypeDescription_covariateMatrix_withMedication.txt \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold}rep${id}_withMedication_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input corrPCs_zscaled \
	--type_sim HK \
	--clusterFile ${fold}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_rep${id}.RData



