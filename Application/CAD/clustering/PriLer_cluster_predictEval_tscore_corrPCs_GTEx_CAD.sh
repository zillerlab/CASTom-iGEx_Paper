#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_predictEval_tscore_corrPCs_CAD_t%a_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/cluster_predictEval_tscore_corrPCs_CAD_t%a_%x.err
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --mem=20G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
name_cohort=(German1 German2 German3 German4 German5 CG WTCCC LURIC MG)
# name_cohort=(German5)

mkdir -p OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/Meta_Analysis_CAD/CAD_HARD_clustering/update_corrPCs/
fold_mod=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
clus_pred=()
pheno_pred=()
feat_rel=()
for i in ${name_cohort[@]}
do
	clus_pred+=(OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${i}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_predictClusterCases_PGmethod_HKmetric.RData)
        pheno_pred+=(INPUT_DATA_GTEx/CAD/Covariates/${i}/phenotypeMatrix_CADrel_Cases.txt)
	feat_rel+=(OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${i}/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscoreOriginal_corrPCs_tscoreClusterCases_featAssociation.RData)
done

feat_rel_model=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscoreOriginal_corrPCs_tscoreClusterCases_featAssociation.RData
gene_loci=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscore_corrPCs_zscaled_clusterCases_summary_geneLoci_allTissues.txt

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

${git_fold}cluster_predict_evaluate_run.R \
	--cohort_name ${name_cohort[@]} \
	--functR ${git_fold}clustering_functions.R \
	--clustFile ${fold_mod}tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData \
	--clustFile_new ${clus_pred[@]} \
	--type_data tscore_corrPCs \
	--type_cluster Cases \
	--type_input zscaled \
	--phenoNew_file ${pheno_pred[@]} \
	--outFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/Meta_Analysis_CAD/CAD_HARD_clustering/update_corrPCs/ \
	--model_name UKBB \
	--featRel_predict ${feat_rel[@]} \
	--featRel_model ${feat_rel_model} \
	--geneLoci_summ ${gene_loci} 





