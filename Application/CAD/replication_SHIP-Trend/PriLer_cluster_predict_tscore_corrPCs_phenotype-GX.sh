#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predict_endopheno_diff_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predict_endopheno_diff_t%a.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem=30G

cd CAD_shared_SHIP/

for cohort_name in SHIP-TREND
do
 for t in Whole_Blood Liver
 do

#cohort_name=SHIP-TREND
fold_cl=Results/PriLer/${t}/
fold_input=Results/PriLer/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

echo Running ${t} for ${cohort_name} ...

${git_fold}cluster_predict_associatePhenoGLM_run.R \
	--cohort_name ${cohort_name} \
	--functR ${git_fold}clustering_functions.R \
	--clustFile_new ${fold_cl}tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData \
	--type_data tscore_corrPCs \
	--type_cluster Cases \
	--type_input zscaled \
	--outFold ${fold_cl}test_GX_ \
	--model_name UKBB \
	--phenoNew_file SCRIPTS/local/${cohort_name}_GX_pheno.txt \
	--covNew_file SCRIPTS/local/${cohort_name}_GX_covar.txt
 done
done
