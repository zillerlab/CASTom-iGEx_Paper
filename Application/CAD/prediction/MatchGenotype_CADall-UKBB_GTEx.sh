#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/MatchGTEx_%x_%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/MatchGTEx_%x_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

path_input_CAD=/psycl/g/mpsukb/CAD/hrc_imputation/
path_input_UKBB=/psycl/g/mpsukb/UKBB_hrc_imputation/

id_chr=${SLURM_ARRAY_TASK_ID}

Rscript MatchGenotype_CADall-UKBB_GTEx_run.R \
	--inputPred ${path_input_CAD}/German1/oxford/ReplaceDots/correct_REF_ALT/ ${path_input_CAD}/German2/oxford/ReplaceDots/correct_REF_ALT/ ${path_input_CAD}/German3/oxford/ReplaceDots/correct_REF_ALT/ ${path_input_CAD}/German4/oxford/ReplaceDots/correct_REF_ALT/ ${path_input_CAD}/German5/oxford/ReplaceDots/correct_REF_ALT/ ${path_input_CAD}/CG/oxford/ReplaceDots/correct_REF_ALT/ ${path_input_CAD}/LURIC/oxford/ReplaceDots/correct_REF_ALT/ ${path_input_CAD}/MG/oxford/ReplaceDots/correct_REF_ALT/ ${path_input_CAD}/WTCCC/oxford/ReplaceDots/correct_REF_ALT/ ${path_input_UKBB}/oxford/correct_REF_ALT/ \
	--namesPred G1 G2 G3 G4 G5 CG LU MG WTC UKBB \
	--outputPred INPUT_DATA_GTEx/CAD/Genotyping_data/German1/ INPUT_DATA_GTEx/CAD/Genotyping_data/German2/ INPUT_DATA_GTEx/CAD/Genotyping_data/German3/ INPUT_DATA_GTEx/CAD/Genotyping_data/German4/ INPUT_DATA_GTEx/CAD/Genotyping_data/German5/ INPUT_DATA_GTEx/CAD/Genotyping_data/Cardiogenics/ INPUT_DATA_GTEx/CAD/Genotyping_data/LURIC/ INPUT_DATA_GTEx/CAD/Genotyping_data/MIGen/ INPUT_DATA_GTEx/CAD/Genotyping_data/WTCCC/ INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/ \
	--inputTrain /psycl/g/mpsziller/lucia/CAD/eQTL_PROJECT/INPUT_DATA_GTEx/GTEX_v6/Genotyping_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas_ \
	--outputTrain INPUT_DATA_GTEx/GTEX_v6/Genotyping_data/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-CADall-UKBB_ \
	--curChrom chr${id_chr} \
	--freq_pop 0.15

