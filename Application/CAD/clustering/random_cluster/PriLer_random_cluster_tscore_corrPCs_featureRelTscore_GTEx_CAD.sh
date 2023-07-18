#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_CAD_corrPCs_t11_randomREP%a_featRelTscore.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_tscore_CAD_corrPCs_t11_randomREP%a_featRelTscore.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=11

R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id=${SLURM_ARRAY_TASK_ID}
t=Liver

readarray -t tissues_tot < OUTPUT_GTEx/Tissue_CADgwas_final

inputFile=()
pvalresFile=()
geneInfoFile=()
for name_t in ${tissues_tot[@]}
do
	fold_t=OUTPUT_GTEx/predict_CAD/${name_t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
	inputFile+=(${fold_t}predictedTscores_splitGenes)
	pvalresFile+=(${fold_t}pval_CAD_pheno_covCorr.RData)
	geneInfoFile+=(OUTPUT_GTEx/train_GTEx/${name_t}/200kb/CAD_GWAS_bin5e-2/resPrior_regEval_allchr.txt)
done

fold_cl=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/random_cluster/
cov_fold=INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

${git_fold}cluster_associateFeat_corrPCs_run.R \
	--inputFile ${inputFile[@]} \
	--sampleAnnFile ${cov_fold}covariateMatrix_CADHARD_All_phenoAssoc.txt \
	--split_tot 100 \
	--pvalresFile ${pvalresFile[@]} \
    --geneInfoFile ${geneInfoFile[@]} \
	--pval_id 1 \
	--type_data tscore \
	--type_cluster Cases \
	--outFold ${fold_cl}rep${id}_ \
	--functR ${git_fold}clustering_functions.R \
	--type_input zscaled \
	--clusterFile ${fold_cl}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_rep${id}.RData \
	--type_data_cluster tscore \
	--ncores 11 \
	--tissues ${tissues_tot[@]}
 

