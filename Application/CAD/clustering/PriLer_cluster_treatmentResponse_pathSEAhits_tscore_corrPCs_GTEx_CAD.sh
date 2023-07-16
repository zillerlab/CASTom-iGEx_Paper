#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_treatResponse_CAD_liver_treat%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_corrPCs_treatResponse_CAD_liver_treat%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G


R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

# prepare input
Rscript get_common_treatments_pathSEA_liverCL.R

id_treat=${SLURM_ARRAY_TASK_ID}
readarray -t treatments < INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/pathSEA/treatment_names
treat_name=$(eval echo "\${treatments[${id_treat}-1]}")
t=Liver

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

${git_fold}cluster_treatmentResponseAnalysis_run.R \
	--covDatFile ${cov_fold}pathSEA/covariateMatrix_${treat_name}.txt \
	--phenoDatFile ${cov_fold}phenotypeMatrix_CADHARD_All_phenoAssoc_withMedication.txt \
	--phenoDescFile ${cov_fold}phenotypeDescription_withMedication.txt \
	--phenoDescCovFile ${cov_fold}pathSEA/phenotypeDescription_Covariates_tot.txt \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold}pathSEA/${treat_name}_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input corrPCs_zscaled \
	--type_sim HK \
	--clusterFile ${fold}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData



