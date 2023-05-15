#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/plot_eval_risk_score_CAD_tscore.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/plot_eval_risk_score_CAD_tscore.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

#readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
tissues=(Adipose_Subcutaneous Adipose_Visceral_Omentum Adrenal_Gland Artery_Aorta Artery_Coronary Colon_Sigmoid Colon_Transverse Heart_Atrial_Appendage Heart_Left_Ventricle Liver Whole_Blood)

in_file=()
for t in ${tissues[@]}
do
in_file+=(OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/tscore_corr2Thr0.1_relatedPhenotypes_R2_risk_score_phenotype.txt)
done
fold_out=OUTPUT_GTEx/predict_CAD/AllTissues/200kb/CAD_GWAS_bin5e-2/UKBB/CAD_HARD_clustering/update_corrPCs/

${git_fold}plot_evaluate_risk_score_run.R \
	--tissues ${tissues[@]} \
	--riskScore_eval_file ${in_file[@]} \
	--outFold ${fold_out} \
	--color_tissues_file /psycl/g/mpsziller/lucia/castom-igex/refData/color_tissues.txt \
