#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predict_tscore_t%a_featRelTscore.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/cluster_predict_tscore_t%a_featRelTscore.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=20G
#SBATCH --cpus-per-task=2

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_SHIP/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < Tissues
t=$(eval echo "\${tissues[${id_t}-1]}")
cohort_name=SHIP-TREND

readarray -t tissues_tot < Tissues

inputFile=()
pvalresFile=()
geneInfoFile=()
for name_t in ${tissues_tot[@]}
do
	fold_t=Results/PriLer/${name_t}/
	fold_mod=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/${name_t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
	inputFile+=(${fold_t}predictedTscores.txt)
	pvalresFile+=(${fold_mod}pval_CAD_pheno_covCorr.RData)
	geneInfoFile+=(PRILER_MODELS/${name_t}/resPrior_regEval_allchr.txt)
done

fold_cl=Results/PriLer/${t}/
cov_fold=Results/PriLer/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

${git_fold}cluster_associateFeat_corrPCs_run.R \
	--inputFile ${inputFile[@]} \
	--sampleAnnFile ${cov_fold}SHIP-TREND_gPC_SHIP_2022_27_withSex.txt \
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
	--ncores 2 \
	--tissues ${tissues_tot[@]}

