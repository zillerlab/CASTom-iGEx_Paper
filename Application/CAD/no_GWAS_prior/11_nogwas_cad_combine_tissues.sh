#!/bin/bash

#SBATCH --job-name=ngccmbts
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=40G


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

export R_LIBS_USER="$HOME/R-4.2.1/library"


l=/scratch/tmp/dolgalev/castom-igex-revision/OUTPUT_CAD/predict_CAD

mkdir -p "${l}/AllTissues/200kb/CAD_GWAS_bin5e-2_nogwas/Meta_Analysis_CAD" 
mkdir -p "${l}/AllTissues/200kb/CAD_GWAS_bin5e-2/Meta_Analysis_CAD" 


Rscript create_txt_allTissues_CAD_CardioGram_no_gwas.R