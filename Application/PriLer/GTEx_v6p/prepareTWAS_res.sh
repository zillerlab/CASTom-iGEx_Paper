#!/bin/bash

readarray -t tissues_name < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv)

cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v7
for t in ${tissues_name[@]}
do
	tar -xf GTEx.${t}.P01.tar
	rm GTEx.${t}.P01.tar
done
echo "GTEx_v7 finished"

Rscript write_gene_profile_TWAS.R
