#!/bin/bash
#SBATCH -o /psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/err_out_fold/totalSplit.out
#SBATCH -e /psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/err_out_fold/totalSplit.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10MB

jid1=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --job-name=splitGen_chr1 splitGen_chr.sh 1)
jid2=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --job-name=splitGen_chr2 splitGen_chr.sh 2)
jid3=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2 --job-name=splitGen_chr3 splitGen_chr.sh 3)
jid4=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3 --job-name=splitGen_chr4 splitGen_chr.sh 4)
jid5=$(sbatch --array=1-100%70 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4  --job-name=splitGen_chr5 splitGen_chr.sh 5)
jid6=$(sbatch --array=1-100%70 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5 --job-name=splitGen_chr6 splitGen_chr.sh 6)
jid7=$(sbatch --array=1-100%70 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6 --job-name=splitGen_chr7 splitGen_chr.sh 7)
jid8=$(sbatch --array=1-100%70 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7 --job-name=splitGen_chr8 splitGen_chr.sh 8)
jid9=$(sbatch --array=1-100%70 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8 --job-name=splitGen_chr9 splitGen_chr.sh 9)
jid10=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9 --job-name=splitGen_chr10 splitGen_chr.sh 10)
jid11=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10 --job-name=splitGen_chr11 splitGen_chr.sh 11)
jid12=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11 --job-name=splitGen_chr12 splitGen_chr.sh 12)
jid13=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12 --job-name=splitGen_chr13 splitGen_chr.sh 13)
jid14=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13 --job-name=splitGen_chr14 splitGen_chr.sh 14)
jid15=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14 --job-name=splitGen_chr15 splitGen_chr.sh 15)
jid16=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15 --job-name=splitGen_chr16 splitGen_chr.sh 16)
jid17=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16 --job-name=splitGen_chr17 splitGen_chr.sh 17)
jid18=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17 --job-name=splitGen_chr18 splitGen_chr.sh 18)
jid19=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18 --job-name=splitGen_chr19 splitGen_chr.sh 19)
jid20=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19 --job-name=splitGen_chr20 splitGen_chr.sh 20)
jid21=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19:$jid20 --job-name=splitGen_chr21 splitGen_chr.sh 21)
jid22=$(sbatch --array=1-100 --parsable --exclude psycl[10-15] --dependency=afterany:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19:$jid20:$jid21 --job-name=splitGen_chr22 splitGen_chr.sh 22)


