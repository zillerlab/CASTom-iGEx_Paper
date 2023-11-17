#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.err

ncores=$1
f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/Software/model_training/

for i in $(seq 22)
do
	echo 'chr' $i

	${git_fold}PriLer_part1_run.R  --curChrom chr$i --covDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt --genoDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchUKBB/Genotype_data/Genotype_dosage_ --geneExp_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchUKBB/RNAseq_data/EXCLUDE_ANCESTRY_SVA/RNAseq_filt.txt --ncores ${ncores} --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_UKBB_SCRIPTS_v2/train_All/200kb/ --InfoFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_UKBB_SCRIPTS_v2/ --functR ${git_fold}PriLer_functions_run.R 

done
 

