#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/plot_eval_risk_score_tscore.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/plot_eval_risk_score_tscore.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=30G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

readarray -t tissues < /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/Meta_Analysis_SCZ/Tissues_PGC_red2

in_file=()
for t in ${tissues[@]}
do
	if [[ "${t}" == "DLPC_CMC" ]]
	then
		in_file+=(OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/update_corrPCs/matchPGC_tscore_corr2Thr0.1_relatedPhenotypes_R2_risk_score_phenotype.txt)
	else
		in_file+=(OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/update_corrPCs/matchPGC_tscore_corr2Thr0.1_relatedPhenotypes_R2_risk_score_phenotype.txt)
	fi
done

fold_out=OUTPUT_all/update_corrPCs/
mkdir -p ${fold_out}

${git_fold}plot_evaluate_risk_score_run.R \
	--tissues ${tissues[@]} \
	--riskScore_eval_file ${in_file[@]} \
	--outFold ${fold_out}matchPGC_ \
	--color_tissues_file /psycl/g/mpsziller/lucia/castom-igex/refData/color_tissues.txt \

