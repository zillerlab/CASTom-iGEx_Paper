#!/bin/bash

############### TWAS (GTEx v7) ###############
readarray -t tissues_name < <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv)

cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v7
touch n_samples
for t in ${tissues_name[@]}
do
	cat n_samples <(head -2 ${t}.P01.pos | awk '{print $7}' | tail -1) >> n_samples
	 
done

paste -d "\t" <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv) <(cat n_samples) > n_samples_allTissues.txt
rm n_samples

############### prediXcan (GTEx v6p) ###############
cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prediXcan/GTEx_v6p/
touch n_samples
for t in ${tissues_name[@]}
do
	cat n_samples <(tail -1 TW_${t}/sample_info.txt) >> n_samples
	 
done

paste -d "\t" <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv) <(cat n_samples) > n_samples_allTissues.txt
rm n_samples

############### prediXcan (GTEx v7) ###############
cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prediXcan/GTEx_v7/
touch n_samples
for t in ${tissues_name[@]}
do
	cat n_samples <(tail -1 ${t}/sample_info.txt| awk '{print $1}') >> n_samples
	 
done

paste -d "\t" <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv) <(cat n_samples) > n_samples_allTissues.txt
rm n_samples

############### PriLer (GTEx v6p) ###############
cd /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/
touch n_samples
for t in ${tissues_name[@]}
do
	cat n_samples <(wc -l ${t}/covariates_EuropeanSamples.txt | awk '{print $1}') >> n_samples
done

paste -d "\t" <(cut -d, -f1 /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv) <(cat n_samples) > n_samples_allTissues.txt
rm n_samples

