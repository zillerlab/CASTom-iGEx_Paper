#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.err
#SBATCH --mem-per-cpu=10MB
#SBATCH -c 1
#SBATCH -p hp

type_name=$1

# part1
jid1=$(sbatch --job-name=${type_name}_p1 --parsable -c 30 --mem-per-cpu=2G ElNet_withPrior_part1_200kb.sh ${type_name} 30)

# part2 
jid2=$(sbatch --job-name=${type_name}_p2 --parsable --dependency=afterany:$jid1 -c 10 --mem-per-cpu=12G -p hp ElNet_withPrior_part2_200kb.sh ${type_name} 10)

# part3
jid3=$(sbatch --job-name=${type_name}_p3 --dependency=afterany:$jid1:$jid2 -c 12 --mem-per-cpu=3500MB -p hp ElNet_withPrior_part3_200kb.sh ${type_name} 12)
	
# part4
jid4=$(sbatch --job-name=${type_name}_p4 --dependency=afterany:$jid1:$jid2:$jid3 -c 12 --mem-per-cpu=2G -p hp ElNet_withPrior_part4_200kb.sh ${type_name} 12)
			
# combine output
jid_out=$(sbatch --job-name=${type_name}_out --dependency=afterany:$jid1:$jid2:$jid3:$jid4 -c 1 --mem-per-cpu=5G ElNet_withPrior_finalOut_200kb.sh ${type_name})
