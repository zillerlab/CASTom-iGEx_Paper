#!/bin/bash

sbatch --job-name ngc3gavo nogwas_cad_priler_part3_with_gwas_var_tissue.sh Adipose_Visceral_Omentum
sbatch --job-name ngc3navo nogwas_cad_priler_part3_no_gwas_var_tissue.sh Adipose_Visceral_Omentum

sbatch --job-name ngc3gaao nogwas_cad_priler_part3_with_gwas_var_tissue.sh Artery_Aorta
sbatch --job-name ngc3naao nogwas_cad_priler_part3_no_gwas_var_tissue.sh Artery_Aorta

sbatch --job-name ngc3gliv nogwas_cad_priler_part3_with_gwas_var_tissue.sh Liver
sbatch --job-name ngc3nliv nogwas_cad_priler_part3_no_gwas_var_tissue.sh Liver