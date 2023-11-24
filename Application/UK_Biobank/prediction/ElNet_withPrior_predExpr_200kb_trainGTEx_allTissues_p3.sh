#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/predExpr_GTEx_alltissues_p3.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/predExpr_GTEx_alltissues_p3.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10MB

jid1=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --job-name=t23 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 23)
jid2=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1 --job-name=t24 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 24)
jid3=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2 --job-name=t25 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 25)
jid4=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3 --job-name=t26 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 26)
jid5=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4 --job-name=t27 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 27)
jid6=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5 --job-name=t28 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 28)
jid7=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6 --job-name=t29 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 29)
jid8=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7 --job-name=t30 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 30)
jid9=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8 --job-name=t31 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 31)
jid10=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9 --job-name=t32 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 32)
jid11=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10 --job-name=t33 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 33)

