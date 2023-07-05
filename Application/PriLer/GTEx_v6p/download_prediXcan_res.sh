#!/bin/bash

readarray -t tissues_name < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv)

# get GTEx_v6p version 
cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prediXcan/GTEx_v6p/
for t in ${tissues_name[@]}
do
	wget https://s3.amazonaws.com/predictdb2/deprecated/download-by-tissue-HapMap/TW_${t}.tar.gz
	tar -xf TW_${t}.tar.gz
	rm TW_${t}.tar.gz
done
echo "GTEx_v6p finished"

# get GTEx_v7 version (only european)
cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prediXcan/GTEx_v7/
for t in ${tissues_name[@]}
do
        wget  https://s3.amazonaws.com/predictdb2/download-by-tissue/${t}.tar.gz
        tar -xf ${t}.tar.gz
        rm ${t}.tar.gz
done
echo "GTEx_v7 finished"
