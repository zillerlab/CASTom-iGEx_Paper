#!/bin/bash

#SBATCH --job-name=fmtucdos
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err

#SBATCH --partition=long
#SBATCH --time=3-00:00:00
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=3G


module load palma/2022a GCC/11.3.0 OpenMPI/4.1.4 Python/3.10.4 SciPy-bundle/2022.05


python -u format_ukbb_cad_dosage.py