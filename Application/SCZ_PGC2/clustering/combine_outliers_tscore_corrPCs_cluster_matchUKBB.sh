#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/combine_outliers_tscore_zscaled_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/combine_outliers_tscore_zscaled_matchUKBB.err
#SBATCH -N 1
#SBATCH --mem=2G
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2


module load 2022
module load R/4.2.1-foss-2022a
git_fold=${HOME}/castom-igex/Software/model_clustering/

readarray -t tissues < ${HOME}/eQTL_PROJECT/OUTPUT_GTEx/Tissue_PGCgwas_red
cd ${HOME}/eQTL_PROJECT/
mkdir -p OUTPUT_all/clustering_res_matchUKBB_corrPCs/

# file_input=(OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_umap_oultiers.txt OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_umap_oultiers.txt)
file_input=(OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_umap_oultiers.txt)

for t in ${tissues[@]}
do
	echo ${t}
	file_input+=(OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_umap_oultiers.txt)
	# file_input+=(OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_umap_oultiers.txt)
done

${git_fold}combine_outliers_cluster_run.R \
	--sampleFiles ${file_input[@]} \
	--type_cluster Cases \
	--type_data tscore \
	--type_input corrPCs_zscaled \
	--outFold OUTPUT_all/clustering_res_matchUKBB_corrPCs/matchUKBB_corr0.9_



