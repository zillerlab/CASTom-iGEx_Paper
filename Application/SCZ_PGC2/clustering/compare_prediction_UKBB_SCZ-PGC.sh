#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/corr_pred_SCZ_UKBB_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/corr_pred_SCZ_UKBB_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/

git_fold=castom-igex/Software/model_clustering/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < SCZ_PGC/eQTL_PROJECT/Meta_Analysis_SCZ/Tissues_PGC_red2
t=$(eval echo "\${tissues[${id_t}-1]}")


pred_from_UKBB=PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_UKBB/$t/200kb/noGWAS/predict/
pred_from_SCZ=PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2_SCZ-PGC/$t/200kb/PGC_GWAS_bin1e-2/predict/


${git_fold}compare_geneExp_matchedDataset_run.R \
	--tissue_name $t \
	--outFold compare_prediction_UKBB_SCZ-PGC/ \
	--geneExpPred_file ${pred_from_UKBB}predictedExpression.txt.gz ${pred_from_SCZ}predictedExpression.txt.gz

echo "genes correlation completed"


${git_fold}compare_pathScore_matchedDataset_run.R \
	--tissue_name $t \
	--type_path GO \
	--outFold compare_prediction_UKBB_SCZ-PGC/ \
	--pathScore_file ${pred_from_UKBB}Pathway_GO_scores.txt ${pred_from_SCZ}Pathway_GO_scores.txt

echo "pathway GO correlation completed"



${git_fold}compare_pathScore_matchedDataset_run.R \
	--tissue_name $t \
	--type_path Reactome \
	--outFold compare_prediction_UKBB_SCZ-PGC/ \
	--pathScore_file ${pred_from_UKBB}Pathway_Reactome_scores.txt ${pred_from_SCZ}Pathway_Reactome_scores.txt

echo "pathway Reactome correlation completed"

