#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.err

ncores=$1
f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/Software/model_training/

for i in $(seq 22)
do
	echo 'chr' $i

	${git_fold}PriLer_part1_run.R  \
		--curChrom chr$i \
		--covDat_file ${f}PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt \
		--genoDat_file ${f}PriLer_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/Genotype_dosage_caucasian_maf001_info06_ \
		--geneExp_file ${f}PriLer_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/CMC/RNAseq_data/EXCLUDE_ANCESTRY_SVA/RNAseq_filt.txt \
		--ncores ${ncores} \
		--outFold ${f}PriLer_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/ \
		--InfoFold ${f}PriLer_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/ \
		--functR ${git_fold}PriLer_functions_run.R 

done
 

