#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/predExpr_GTEx_alltissues_p2.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/predExpr_GTEx_alltissues_p2.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10MB

jid1=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --job-name=t12 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 12)
jid2=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1 --job-name=t13 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 13)
jid3=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2 --job-name=t14 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 14)
jid4=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3 --job-name=t15 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 15)
jid5=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4 --job-name=t16 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 16)
jid6=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5 --job-name=t17 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 17)
jid7=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6 --job-name=t18 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 18)
jid8=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7 --job-name=t19 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 19)
jid9=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8 --job-name=t20 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 20)
jid10=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9 --job-name=t21 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 21)
jid11=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10 --job-name=t22 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 22)

