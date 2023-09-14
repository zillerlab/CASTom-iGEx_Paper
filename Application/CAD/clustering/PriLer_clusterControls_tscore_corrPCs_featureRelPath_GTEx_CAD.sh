#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_controls_tscore_CAD_corrPCs_t%a_featRelPath.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_controls_tscore_CAD_corrPCs_t%a_featRelPath.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=70G

module load r_anaconda/4.0.3
R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

readarray -t tissues_tot < OUTPUT_GTEx/Tissue_CADgwas_final

inputFold=()
pvalresFile=()
for name_t in ${tissues_tot[@]}
do
	fold_t=OUTPUT_GTEx/predict_CAD/${name_t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
	inputFold+=(${fold_t})
	pvalresFile+=(${fold_t}pval_CAD_pheno_covCorr.RData)
done

fold_cl=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

${git_fold}cluster_associatePath_corrPCs_run.R \
	--inputFold ${inputFold[@]} \
	--sampleAnnFile ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc.txt \
	--pvalresFile ${pvalresFile[@]} \
	--pval_id 1 \
	--type_cluster Controls \
	--outFold ${fold_cl} \
	--functR ${git_fold}clustering_functions.R \
	--type_input zscaled \
	--clusterFile ${fold_cl}tscore_corrPCs_zscaled_clusterControls_PGmethod_HKmetric.RData \
	--type_data_cluster tscore \
	--ncores 6 \
	--tissues ${tissues_tot[@]}
 


