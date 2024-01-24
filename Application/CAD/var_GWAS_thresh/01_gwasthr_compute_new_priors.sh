#!/bin/bash

#SBATCH --job-name=gthcprio
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=1


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/PriLer_PROJECT_GTEx
l=/scratch/tmp/dolgalev/castom-igex-revision/PriLer_PROJECT_GTEx


# Run modified script for computing priors with variable p value threshold from GWAS data
for i in $(seq 22); do
  Rscript Compute_priorMat_fin_run_var_gwas_thresh.R \
    --chr ${i} \
    --inputDir "${c}/OUTPUT/" \
    --outputDir "${l}/OUTPUT_SCRIPTS_v2/" \
    --VarInfo_file "${c}/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_"
done


# Add new priors to the global prior index, save the new index locally
Rscript index_new_priors.R


t=Artery_Coronary

for p in p00001 p0001 p001 p005 p01; do
  mkdir -p "${l}/OUTPUT_SCRIPTS_v2/${t}/200kb/CAD_GWAS_bin_${p}"

  # Get tissue-specific priors, replace CAD_GWAS_bin5e-2 with a different p value threshold prior
  awk -F "," -v a="$t" '$1==a' "${c}/INPUT_DATA/prior_association_CADgwas.csv" \
    | sed -r -e 's/("([^"]*)")?,/\2\t/g' \
    | grep -oP '\S+' \
    | sed "s/CAD_gwas_bin/CAD_gwas_bin_${p}/" > "${l}/OUTPUT_SCRIPTS_v2/${t}/priorName_CAD_AC_gwas_${p}.txt"

  awk 'NR==FNR{_[$1];next}($2 in _)' "${l}/OUTPUT_SCRIPTS_v2/${t}/priorName_CAD_AC_gwas_${p}.txt" \
    "${l}/OUTPUT_SCRIPTS_v2/allPriorName.txt" > \
    "${l}/OUTPUT_SCRIPTS_v2/${t}/priorName_CAD_AC_gwas_${p}_withIndex.txt"

  rm "${l}/OUTPUT_SCRIPTS_v2/${t}/priorName_CAD_AC_gwas_${p}.txt"
done


t=Brain_Cortex

for p in p00001 p0001 p001 p005 p01; do
  mkdir -p "${l}/OUTPUT_SCRIPTS_v2/${t}/200kb/PGC_GWAS_bin_${p}"

  awk -F "," -v a="$t" '$1==a' "${c}/INPUT_DATA/prior_association_PGCgwas.csv" \
    | sed -r -e 's/("([^"]*)")?,/\2\t/g' \
    | grep -oP '\S+' \
    | sed "s/PGC_gwas_bin/PGC_gwas_bin_${p}/" > "${l}/OUTPUT_SCRIPTS_v2/${t}/priorName_PGC_BC_gwas_${p}.txt"

  awk 'NR==FNR{_[$1];next}($2 in _)' "${l}/OUTPUT_SCRIPTS_v2/${t}/priorName_PGC_BC_gwas_${p}.txt" \
    "${l}/OUTPUT_SCRIPTS_v2/allPriorName.txt" > \
    "${l}/OUTPUT_SCRIPTS_v2/${t}/priorName_PGC_BC_gwas_${p}_withIndex.txt"
  
  rm "${l}/OUTPUT_SCRIPTS_v2/${t}/priorName_PGC_BC_gwas_${p}.txt"
done