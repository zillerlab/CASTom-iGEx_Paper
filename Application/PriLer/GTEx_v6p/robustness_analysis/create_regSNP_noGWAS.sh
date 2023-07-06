#!/bin/bash

Rscript create_regSNP_ann.R 

gzip /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resPrior_regSNPs_annotation.txt
gzip /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resNoPrior_regSNPs_annotation.txt
gzip /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resPrior_regSNPs_reliableGenes_annotation.txt
gzip /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resNoPrior_regSNPs_reliableGenes_annotation.txt
gzip /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resPrior_regSNPs_heritableGenes_annotation.txt
gzip /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resNoPrior_regSNPs_heritableGenes_annotation.txt
gzip /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resPrior_regSNPs_prediXcangenes_annotation.txt
gzip /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/resPrior_regSNPs_TWASgenes_annotation.txt

Rscript create_regSNP_ann_prediXcan_TWAS.R

gzip /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/TWAS_regSNPs_annotation.txt
gzip /psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/AllTissues/200kb/noGWAS/prediXcan_regSNPs_annotation.txt



