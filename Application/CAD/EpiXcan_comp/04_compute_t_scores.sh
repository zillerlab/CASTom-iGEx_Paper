#!/bin/bash

sbatch --array=1-100%10 compute_t_scores_var_split.sh