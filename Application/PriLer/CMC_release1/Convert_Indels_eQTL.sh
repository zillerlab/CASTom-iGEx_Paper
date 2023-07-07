#!/bin/bash
#SBATCH --job-name=conv
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/conv_indels_%A_chr%a.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/conv_indels_%A_chr%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH -c 1
#SBATCH -p hp

export PERL5LIB=/ziller/Software/Perl/share/perl5

id_chr=${SLURM_ARRAY_TASK_ID}

converter=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/PERL_SCRIPTS/gen2me.pl
genfile=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/INDELS/filtered_chr${id_chr}_corRefAlt_indels.gen
samplefile=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/INDELS/filtered_chr${id_chr}_corRefAlt_indels.sample
outfile=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/INDELS/filtered_chr${id_chr}_corRefAlt_indels

perl $converter --gen=$genfile --sample=$samplefile --out=$outfile

#######################################
# convert to eqtl standard format

converter2=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/PYTH_SCRIPTS/ziller_matrix_convertion.py

python $converter2 $outfile'.geno'

## remove intermediate conversion
rm $outfile'.geno'

###############
echo "chr ${id_chr} finished"
##############

