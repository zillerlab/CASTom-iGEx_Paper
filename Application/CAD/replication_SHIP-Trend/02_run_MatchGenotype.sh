#!/bin/sh

for chr in {1..22}
do
    Rscript MatchGenotype_CADall-UKBB_GTEx_SHIP_run.R chr${chr} | tee MatchGenotype_CADall-UKBB_GTEx_run-chr${chr}.log
done


