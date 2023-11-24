#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/totalConvert_matchGTEx.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/totalConvert_matchGTEx.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10MB

jid1=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --job-name=mGTEx_chr1 convertDosage_corrREFALT_matchedGTEx.sh 1)
jid2=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1 --job-name=mGTEx_chr2 convertDosage_corrREFALT_matchedGTEx.sh 2)
jid3=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2 --job-name=mGTEx_chr3 convertDosage_corrREFALT_matchedGTEx.sh 3)
jid4=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3 --job-name=mGTEx_chr4 convertDosage_corrREFALT_matchedGTEx.sh 4)
jid5=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4  --job-name=mGTEx_chr5 convertDosage_corrREFALT_matchedGTEx.sh 5)
jid6=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5 --job-name=mGTEx_chr6 convertDosage_corrREFALT_matchedGTEx.sh 6)
jid7=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6 --job-name=mGTEx_chr7 convertDosage_corrREFALT_matchedGTEx.sh 7)
jid8=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7 --job-name=mGTEx_chr8 convertDosage_corrREFALT_matchedGTEx.sh 8)
jid9=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8 --job-name=mGTEx_chr9 convertDosage_corrREFALT_matchedGTEx.sh 9)
jid10=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9 --job-name=mGTEx_chr10 convertDosage_corrREFALT_matchedGTEx.sh 10)
jid11=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10 --job-name=mGTEx_chr11 convertDosage_corrREFALT_matchedGTEx.sh 11)
jid12=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11 --job-name=mGTEx_chr12 convertDosage_corrREFALT_matchedGTEx.sh 12)
jid13=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12 --job-name=mGTEx_chr13 convertDosage_corrREFALT_matchedGTEx.sh 13)
jid14=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13 --job-name=mGTEx_chr14 convertDosage_corrREFALT_matchedGTEx.sh 14)
jid15=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14 --job-name=mGTEx_chr15 convertDosage_corrREFALT_matchedGTEx.sh 15)
jid16=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15 --job-name=mGTEx_chr16 convertDosage_corrREFALT_matchedGTEx.sh 16)
jid17=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16 --job-name=mGTEx_chr17 convertDosage_corrREFALT_matchedGTEx.sh 17)
jid18=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17 --job-name=mGTEx_chr18 convertDosage_corrREFALT_matchedGTEx.sh 18)
jid19=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18 --job-name=mGTEx_chr19 convertDosage_corrREFALT_matchedGTEx.sh 19)
jid20=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19 --job-name=mGTEx_chr20 convertDosage_corrREFALT_matchedGTEx.sh 20)
jid21=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19:$jid20 --job-name=mGTEx_chr21 convertDosage_corrREFALT_matchedGTEx.sh 21)
jid22=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid11:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19:$jid20:$jid21 --job-name=mGTEx_chr22 convertDosage_corrREFALT_matchedGTEx.sh 22)

