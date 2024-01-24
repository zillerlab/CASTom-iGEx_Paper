#!/bin/bash

sbatch --wait filter_pathways_js.sh

sbatch --wait cluster_t_score.sh

sbatch --wait cluster_endophenotype_t_score.sh
sbatch --wait cluster_endophenotype_nominal_t_score.sh
sbatch --wait cluster_treatment_response_t_score.sh

sbatch --wait cluster_feature_rel_t_score.sh
sbatch --wiat cluster_feature_rel_path.sh