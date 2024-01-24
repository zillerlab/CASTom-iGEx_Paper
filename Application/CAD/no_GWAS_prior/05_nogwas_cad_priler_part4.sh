#!/bin/bash

sbatch --job-name ngc4gavo nogwas_cad_priler_part4_with_gwas_var_tissue.sh Adipose_Visceral_Omentum
sbatch --job-name ngc4navo nogwas_cad_priler_part4_no_gwas_var_tissue.sh Adipose_Visceral_Omentum

sbatch --job-name ngc4gaao nogwas_cad_priler_part4_with_gwas_var_tissue.sh Artery_Aorta
sbatch --job-name ngc4naao nogwas_cad_priler_part4_no_gwas_var_tissue.sh Artery_Aorta

sbatch --job-name ngc4gliv nogwas_cad_priler_part4_with_gwas_var_tissue.sh Liver
sbatch --job-name ngc4nliv nogwas_cad_priler_part4_no_gwas_var_tissue.sh Liver