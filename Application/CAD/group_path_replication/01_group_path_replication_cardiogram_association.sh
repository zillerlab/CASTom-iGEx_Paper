#!/bin/bash

cohorts=(German1 German2 German3 German4 German5 CG LURIC MG WTCCC)
cohort_codes=(g1 g2 g3 g4 g5 cg lu mg wt)


for j in "${!cohorts[@]}"; do
  sbatch --job-name "gpr_cas_${cohort_codes[$j]}" --array=1-11%1 \
    group_path_replication_cardiogram_association_var_tissue_var_cohort.sh "${cohorts[$j]}"
done