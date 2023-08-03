#!/bin/bash
#SBATCH --job-name=match
#SBATCH --output=/ziller/lucia/eQTL_PROJECT_CMC/err_out_fold/match_geno_SCZ-PGC_chr%a_%A.out
#SBATCH --error=/ziller/lucia/eQTL_PROJECT_CMC/err_out_fold/match_geno_SCZ-PGC_chr%a_%A.err
#SBATCH --mem-per-cpu=15G
#SBATCH -c 1
#SBATCH -p pe


id_chr=${SLURM_ARRAY_TASK_ID}

readarray -t cohorts < /ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/SCZ-PGC/SCZ_cohort_names
input_SCZPGC=/ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/SCZ-PGC/Genotype_data/

inputfile_list=()
outputfile_list=()

for c in ${cohorts[@]}
do
	echo ${c}
	inputfile_list+=(${input_SCZPGC}${c}/dos_${c}-qc.chr${id_chr}.out.dosage.filt_maf001_info06_misscount20.gz)
	outputfile_list+=(${input_SCZPGC}${c}/)
done

Rscript /ziller/lucia/eQTL_PROJECT_CMC/RSCRIPTS/Match_CMC_SCZ-PGCall_run.R --namesPred ${cohorts[@]} --inputPred ${inputfile_list[@]} --outputPred ${outputfile_list[@]} --inputTrain /ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/Genotype_VariantsInfo_caucasian_maf001_info06_CMC-PGC_chr${id_chr}.txt --outputTrain /ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA_matchSCZ-PGC/CMC/Genotype_data/Genotype_VariantsInfo_maf001_info06_CMC-PGCgwas-SCZ-PGCall_ --curChrom chr${id_chr}

