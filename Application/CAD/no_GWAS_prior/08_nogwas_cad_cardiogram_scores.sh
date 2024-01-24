#!/bin/bash

tissues=(Adipose_Visceral_Omentum Artery_Aorta Liver)
tissue_codes=(avo aao liv)

cohorts=(German1 German2 German3 German4 German5 CG LURIC MG WTCCC)
cohort_codes=(g1 g2 g3 g4 g5 cg lu mg wt)


for i in "${!tissues[@]}"; do
  for j in "${!cohorts[@]}"; do
    sbatch --job-name "ngc_crdg_sco_n_${tissue_codes[$i]}_${cohort_codes[$j]}" \
      nogwas_cad_cardiogram_scores_no_gwas_var_tissue_var_cohort.sh "${tissues[$i]}" "${cohorts[$j]}"

    sbatch --job-name "ngc_crdg_sco_g_${tissue_codes[$i]}_${cohort_codes[$j]}" \
      nogwas_cad_cardiogram_scores_with_gwas_var_tissue_var_cohort.sh "${tissues[$i]}" "${cohorts[$j]}"
  done
done