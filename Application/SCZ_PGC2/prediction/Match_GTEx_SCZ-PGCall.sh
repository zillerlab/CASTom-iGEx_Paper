#!/bin/bash

id_chr=$1

readarray -t cohorts < /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/SCZ-PGC/SCZ_cohort_names
input_SCZPGC=/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/SCZ-PGC/Genotype_data/

inputfile_list=()
outputfile_list=()

for c in ${cohorts[@]}
do
	echo ${c}
	inputfile_list+=(${input_SCZPGC}${c}/dos_${c}-qc.chr${id_chr}.out.dosage.filt_maf001_info06_misscount20.gz)
	outputfile_list+=(${input_SCZPGC}${c}/)
done

Rscript Match_GTEx_SCZ-PGCall_run.R \
	--namesPred ${cohorts[@]} \
	--inputPred ${inputfile_list[@]} \
	--outputPred ${outputfile_list[@]} \
	--inputTrain /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_caucasian_maf001_info06_CMC-PGCgwas-CADgwas_chr${id_chr}.txt \
	--outputTrain /mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA_matchSCZ-PGC/GTEx/Genotype_data/Genotype_VariantsInfo_maf001_info06_GTEx-PGCgwas-SCZ-PGCall_ \
	--curChrom chr${id_chr}

