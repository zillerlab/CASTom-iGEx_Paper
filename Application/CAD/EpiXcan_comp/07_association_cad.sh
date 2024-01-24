#!/bin/bash

sbatch --wait --array 1-100%20 association_tscores_cad_var_split.sh

sbatch --wait --array 1-100%20 association_reactome_cad_var_split.sh
sbatch --wait --array 1-100%20 association_go_cad_var_split.sh

sbatch --wait association_wikipath_cad.sh

sbatch --wait association_combine_cad.sh