#!/bin/bash

tissues=(Adipose_Visceral_Omentum Artery_Aorta Liver)
tissue_codes=(avo aao liv)


for i in "${!tissues[@]}"; do
  sbatch --job-name "ngc_crdg_meta_n_${tissue_codes[$i]}" \
    nogwas_cad_cardiogram_meta_no_gwas_var_tissue.sh "${tissues[$i]}"

  sbatch --job-name "ngc_crdg_meta_g_${tissue_codes[$i]}" \
    nogwas_cad_cardiogram_meta_with_gwas_var_tissue.sh "${tissues[$i]}"
done