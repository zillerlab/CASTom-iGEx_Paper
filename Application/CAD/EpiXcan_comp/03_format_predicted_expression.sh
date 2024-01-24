#!/bin/bash

#SBATCH --job-name=fmtprdxp
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=2G


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 Python/3.10.4 SciPy-bundle/2022.05


python -u load_biomart_grch37_gene.py

python -u format_predicted_expression.py