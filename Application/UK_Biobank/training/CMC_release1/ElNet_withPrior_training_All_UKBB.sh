#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.err
#SBATCH --mem-per-cpu=10MB
#SBATCH -c 1
#SBATCH -p hp

# part1
jid1=$(sbatch --job-name=UKBB_p1 --parsable -c 30 -p gpu --mem-per-cpu=3G ElNet_withPrior_part1_200kb.sh 30)

# part2 
jid2=$(sbatch --job-name=UKBB_p2 --parsable --dependency=afterany:$jid1 -c 2 --mem-per-cpu=50G -p gpu ElNet_withPrior_part2_200kb.sh 2)

# part3
jid3=$(sbatch --job-name=UKBB_p3 --parsable --dependency=afterany:$jid1:$jid2 -c 25 --mem-per-cpu=4G -p gpu ElNet_withPrior_part3_200kb.sh 25)

# part4
jid4=$(sbatch --job-name=UKBB_p4 --parsable --dependency=afterany:$jid1:$jid2:$jid3 -c 25 --mem-per-cpu=4G -p gpu ElNet_withPrior_part4_200kb.sh 25)

# combine output
jid_out=$(sbatch --job-name=UKBB_out --dependency=afterany:$jid1:$jid2:$jid3:$jid4 -c 1 --mem-per-cpu=15G ElNet_withPrior_finalOut_200kb.sh)
