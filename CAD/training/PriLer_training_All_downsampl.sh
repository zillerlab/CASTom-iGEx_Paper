#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/err_out_fold/%x_200kb.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/err_out_fold/%x_200kb.err
#SBATCH --mem-per-cpu=10MB
#SBATCH --time=10-0
#SBATCH --nodes=1

t=$1
perc=$2

mkdir -p ../../OUTPUT_SCRIPTS_v2_CAD_UKBB/${t}/200kb/downsampling/perc${perc}/

# part1
jid1=$(sbatch --job-name=${t}_${perc}_p1 --parsable --cpus-per-task=20 --mem-per-cpu=3G PriLer_part1_200kb_downsampl.sh 20 $t ${perc})

# part2 
jid2=$(sbatch --job-name=${t}_${perc}_p2 --parsable --dependency=afterany:$jid1 --cpus-per-task=7 --mem-per-cpu=20G PriLer_part2_200kb_downsampl.sh 7 $t ${perc})

# part3
jid3=$(sbatch --job-name=${t}_${perc}_p3 --parsable --dependency=afterany:$jid1:$jid2 --cpus-per-task=20 --mem-per-cpu=3G PriLer_part3_200kb_downsampl.sh 20 $t ${perc})

# part4
jid4=$(sbatch --job-name=${t}_${perc}_p4 --parsable --dependency=afterany:$jid1:$jid2:$jid3 --cpus-per-task=20 --mem-per-cpu=3G PriLer_part4_200kb_downsampl.sh 20 $t ${perc})

# combine output
jid_out=$(sbatch --job-name=${t}_${perc}_out --dependency=afterany:$jid1:$jid2:$jid3:$jid4 --cpus-per-task=1 --mem-per-cpu=15G PriLer_finalOut_200kb_downsampl.sh $t ${perc})
