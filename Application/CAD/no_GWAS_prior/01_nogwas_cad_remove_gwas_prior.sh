#!/bin/bash

#SBATCH --job-name=ngcrgwpr
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=00:01:00
#SBATCH --cpus-per-task=1

# Source: Application/CAD/training/Build_priorIndex_alltissuesCADUKBB.sh


c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/PriLer_PROJECT_GTEx
l=/scratch/tmp/dolgalev/castom-igex-revision/PriLer_PROJECT_GTEx


mkdir -p "${l}/INPUT_DATA"

# Assume CAD_gwas_bin is not in the first column
sed 's/,CAD_gwas_bin//' "${c}/INPUT_DATA/prior_association_CADgwas.csv" > \
  "${l}/INPUT_DATA/prior_association_CAD_nogwas.csv"


for t in Adipose_Visceral_Omentum Artery_Aorta Liver; do
  mkdir -p "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2_nogwas"
  mkdir -p "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/CAD_GWAS_bin5e-2"

  # Extract prior names for a given tissue
  awk -F "," -v a="$t" '$1==a' "${l}/INPUT_DATA/prior_association_CAD_nogwas.csv" \
    | sed -r -e 's/("([^"]*)")?,/\2\t/g' \
    | grep -oP '\S+' > "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CAD_nogwas.txt"

  # Match prior names to indexes, save the result
  awk 'NR==FNR{_[$1];next}($2 in _)' "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CAD_nogwas.txt" \
    "${c}/OUTPUT_SCRIPTS_v2_CAD_UKBB/allPriorName.txt" > \
    "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CAD_nogwas_withIndex.txt"
  
  rm "${l}/OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/priorName_CAD_nogwas.txt"
done