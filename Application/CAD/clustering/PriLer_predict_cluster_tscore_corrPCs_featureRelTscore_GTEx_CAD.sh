#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_CAD_corrPCs_t%a_%x_featRelTscore.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_CAD_corrPCs_t%a_%x_featRelTscore.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=5G
#SBATCH --cpus-per-task=11

R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
cohort_name=$1

readarray -t tissues_tot < OUTPUT_GTEx/Tissue_CADgwas_final

inputFile=()
pvalresFile=()
geneInfoFile=()
for name_t in ${tissues_tot[@]}
do
	fold_t=OUTPUT_GTEx/predict_CAD/${name_t}/200kb/CAD_GWAS_bin5e-2/${cohort_name}/devgeno0.01_testdevgeno0/
	fold_mod=OUTPUT_GTEx/predict_CAD/${name_t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
	inputFile+=(${fold_t}predictedTscores.txt)
	pvalresFile+=(${fold_mod}pval_CAD_pheno_covCorr.RData)
	geneInfoFile+=(OUTPUT_GTEx/train_GTEx/${name_t}/200kb/CAD_GWAS_bin5e-2/resPrior_regEval_allchr.txt)
done

fold_cl=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${cohort_name}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/${cohort_name}/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

${git_fold}cluster_associateFeat_corrPCs_run.R \
	--inputFile ${inputFile[@]} \
	--sampleAnnFile ${cov_fold}covariateMatrix.txt \
	--split_tot 0 \
	--pvalresFile ${pvalresFile[@]} \
    --geneInfoFile ${geneInfoFile[@]} \
	--pval_id 1 \
	--min_genes_path 2 \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold_cl} \
	--functR ${git_fold}clustering_functions.R \
	--type_input zscaled \
	--clusterFile ${fold_cl}tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData \
	--type_data_cluster tscore \
	--ncores 11 \
	--tissues ${tissues_tot[@]}

 


