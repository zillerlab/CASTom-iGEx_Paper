#!/bin/bash
#SBATCH --job-name=match
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/match_geno_SCZ-PGC_chr%a_%A.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/match_geno_SCZ-PGC_chr%a_%A.err
#SBATCH --mem=15G
#SBATCH -N 1


module load R/3.5.3
id_chr=${SLURM_ARRAY_TASK_ID}

readarray -t cohorts < /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/SCZ-PGC/SCZ_cohort_names
input_SCZPGC=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/SCZ-PGC/Genotype_data/

inputfile_list=()
outputfile_list=()

for c in ${cohorts[@]}
do
	echo ${c}
	inputfile_list+=(${input_SCZPGC}${c}/dos_${c}-qc.chr${id_chr}.out.dosage.filt_maf001_info06_misscount20.gz)
	outputfile_list+=(${input_SCZPGC}${c}/)
done

Rscript Match_CMC_SCZ-PGCall_run.R \
	--namesPred ${cohorts[@]} \
	--inputPred ${inputfile_list[@]} \
	--outputPred ${outputfile_list[@]} \
	--inputTrain /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/Genotype_VariantsInfo_caucasian_maf001_info06_CMC-PGC_chr${id_chr}.txt \
	--outputTrain /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/Genotype_VariantsInfo_maf001_info06_CMC-PGCgwas-SCZ-PGCall_ \
	--curChrom chr${id_chr}

