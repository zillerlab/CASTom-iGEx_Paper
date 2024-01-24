#!/bin/bash

c=/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD

readarray -t tissues < "${c}/Tissue_CADgwas_final"


for j in "${!tissues[@]}"; do
  sbatch --job-name "gpr_meta_${j}" group_path_replication_cardiogram_meta_var_tissue.sh "${tissues[$j]}"
done