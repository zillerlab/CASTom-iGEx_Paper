#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/err_out_fold/%x_200kb.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/err_out_fold/%x_200kb.err
#SBATCH --time=10-0

module load R/3.5.3

ncores=$1
t=$2
perc=$3
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_training/

cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/

for i in $(seq 22)
do
	echo 'chr' $i

	${git_fold}/PriLer_part1_run.R  \
		--curChrom chr$i \
		--covDat_file INPUT_DATA/Covariates/${t}/covariates_EuropeanSamples_downsample${perc}.txt  \
		--genoDat_file INPUT_DATA_matchCADall-UKBB/Genotype_data/Genotype_dosage_ \
		--geneExp_file INPUT_DATA_matchCADall-UKBB/RNAseq_data/${t}/RNAseq_filt.txt \
		--ncores ${ncores} \
		--outFold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/ \
		--InfoFold OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/ \
		--functR ${git_fold}PriLer_functions.R 

done

