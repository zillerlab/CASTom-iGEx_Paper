#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/tscore_pathscore_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/tscore_pathscore_t%a.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem=10G


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_SHIP/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
git_ref=/psycl/g/mpsziller/lucia/castom-igex/refData/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < Tissues
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=Results/PriLer/
input_file=${fold}/${t}/SHIP_2022_27_D_SHIP-TREND_${t}_predictedExpression.txt.gz


${git_fold}Tscore_PathScore_diff_run.R \
	--input_file ${input_file} \
	--reactome_file ${git_ref}ReactomePathways.gmt \
	--GOterms_file ${git_ref}GOterm_geneAnnotation_allOntologies.RData \
	--covDat_file ${fold}SHIP-TREND_gPC_SHIP_2022_27_withSex.txt \
	--nFolds 40 \
	--outFold ${fold}/${t}/
