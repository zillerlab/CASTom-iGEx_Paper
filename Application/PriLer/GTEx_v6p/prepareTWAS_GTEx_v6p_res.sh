#!/bin/bash

readarray -t tissues_name < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv)

cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v6p

for t in ${tissues_name[@]}
do
	echo $t
	bzip2 -d GTEx.${t}.tar.bz2
	tar -xf GTEx.${t}.tar
	rm GTEx.${t}.tar
	
done

echo "GTEx_v6p finished"

Rscript write_gene_profile_TWAS_v6p.R

