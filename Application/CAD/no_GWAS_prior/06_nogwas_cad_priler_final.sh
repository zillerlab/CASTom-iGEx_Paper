#!/bin/bash

sbatch --job-name ngcfgavo nogwas_cad_priler_final_with_gwas_var_tissue.sh Adipose_Visceral_Omentum
sbatch --job-name ngcfnavo nogwas_cad_priler_final_no_gwas_var_tissue.sh Adipose_Visceral_Omentum

sbatch --job-name ngcfgaao nogwas_cad_priler_final_with_gwas_var_tissue.sh Artery_Aorta
sbatch --job-name ngcfnaao nogwas_cad_priler_final_no_gwas_var_tissue.sh Artery_Aorta

sbatch --job-name ngcfgliv nogwas_cad_priler_final_with_gwas_var_tissue.sh Liver
sbatch --job-name ngcfnliv nogwas_cad_priler_final_no_gwas_var_tissue.sh Liver