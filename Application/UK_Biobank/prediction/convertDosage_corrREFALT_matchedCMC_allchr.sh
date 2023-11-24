#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/totalConvert_matchCMC.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/totalConvert_matchCMC.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10MB

jid1=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --job-name=mCMC_chr1 convertDosage_corrREFALT_matchedCMC.sh 1)
jid2=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1 --job-name=mCMC_chr2 convertDosage_corrREFALT_matchedCMC.sh 2)
jid3=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2 --job-name=mCMC_chr3 convertDosage_corrREFALT_matchedCMC.sh 3)
jid4=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3 --job-name=mCMC_chr4 convertDosage_corrREFALT_matchedCMC.sh 4)
jid5=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4  --job-name=mCMC_chr5 convertDosage_corrREFALT_matchedCMC.sh 5)
jid6=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5 --job-name=mCMC_chr6 convertDosage_corrREFALT_matchedCMC.sh 6)
jid7=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6 --job-name=mCMC_chr7 convertDosage_corrREFALT_matchedCMC.sh 7)
jid8=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7 --job-name=mCMC_chr8 convertDosage_corrREFALT_matchedCMC.sh 8)
jid9=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8 --job-name=mCMC_chr9 convertDosage_corrREFALT_matchedCMC.sh 9)
jid10=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9 --job-name=mCMC_chr10 convertDosage_corrREFALT_matchedCMC.sh 10)
jid11=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10 --job-name=mCMC_chr11 convertDosage_corrREFALT_matchedCMC.sh 11)
jid12=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11 --job-name=mCMC_chr12 convertDosage_corrREFALT_matchedCMC.sh 12)
jid13=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12 --job-name=mCMC_chr13 convertDosage_corrREFALT_matchedCMC.sh 13)
jid14=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13 --job-name=mCMC_chr14 convertDosage_corrREFALT_matchedCMC.sh 14)
jid15=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14 --job-name=mCMC_chr15 convertDosage_corrREFALT_matchedCMC.sh 15)
jid16=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15 --job-name=mCMC_chr16 convertDosage_corrREFALT_matchedCMC.sh 16)
jid17=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16 --job-name=mCMC_chr17 convertDosage_corrREFALT_matchedCMC.sh 17)
jid18=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17 --job-name=mCMC_chr18 convertDosage_corrREFALT_matchedCMC.sh 18)
jid19=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18 --job-name=mCMC_chr19 convertDosage_corrREFALT_matchedCMC.sh 19)
jid20=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19 --job-name=mCMC_chr20 convertDosage_corrREFALT_matchedCMC.sh 20)
jid21=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19:$jid20 --job-name=mCMC_chr21 convertDosage_corrREFALT_matchedCMC.sh 21)
jid22=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19:$jid20:$jid21 --job-name=mCMC_chr22 convertDosage_corrREFALT_matchedCMC.sh 22)

