#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/combine_outliers_tscore_zscaled_matchUKBB.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/combine_outliers_tscore_zscaled_matchUKBB.err
#SBATCH -N 1
#SBATCH -p short


module load 2019
module load R/3.5.1-intel-2019b

readarray -t tissues < /home/luciat/eQTL_PROJECT/OUTPUT_GTEx/Tissue_PGCgwas_red
cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/priler_project/Software/model_clustering/

file_input=(OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_umap_oultiers.txt OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_umap_oultiers.txt)

for t in ${tissues[@]}
do
	echo ${t}
	file_input+=(OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_umap_oultiers.txt)
	file_input+=(OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_filt0.1_tscore_corrPCs_zscaled_clusterCases_PGmethod_umap_oultiers.txt)
done

Rscript ${git_fold}combine_outliers_cluster_run.R --sampleFiles ${file_input[@]} --type_cluster Cases --type_data tscore --type_input corrPCs_zscaled --outFold OUTPUT_all/matchUKBB_



