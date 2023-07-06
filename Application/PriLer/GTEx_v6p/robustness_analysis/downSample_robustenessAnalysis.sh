#!/bin/bash

Rscript downSample_cov_run.R \
    --covDat /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/Whole_Blood/covariates_EuropeanSamples.txt \
    --n_samples 100 \
    --n_rep 30 \
    --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/Whole_Blood/robustness_analysis/

