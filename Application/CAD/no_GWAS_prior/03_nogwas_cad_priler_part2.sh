#!/bin/bash

sbatch --job-name ngc2gavo nogwas_cad_priler_part2_with_gwas_var_tissue_var_e.sh Adipose_Visceral_Omentum 1 1.5 2 2.5 3 3.5
sbatch --job-name ngc2navo nogwas_cad_priler_part2_no_gwas_var_tissue_var_e.sh Adipose_Visceral_Omentum 1 1.5 2 2.5 3 3.5

sbatch --job-name ngc2gaao nogwas_cad_priler_part2_with_gwas_var_tissue_var_e.sh Artery_Aorta 4 5 6 7 8 9
sbatch --job-name ngc2naao nogwas_cad_priler_part2_no_gwas_var_tissue_var_e.sh Artery_Aorta 4 5 6 7 8 9

sbatch --job-name ngc2gliv nogwas_cad_priler_part2_with_gwas_var_tissue_var_e.sh Liver 0.5 0.75 1 1.25 1.5 2
sbatch --job-name ngc2nliv nogwas_cad_priler_part2_no_gwas_var_tissue_var_e.sh Liver 0.5 0.75 1 1.25 1.5 2