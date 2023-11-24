#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/predExpr_GTEx_alltissues_p1.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/predExpr_GTEx_alltissues_p1.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10MB

jid1=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --job-name=t1 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 1)
jid2=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1 --job-name=t2 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 2)
jid3=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2 --job-name=t3 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 3)
jid4=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3 --job-name=t4 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 4)
jid5=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4 --job-name=t5 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 5)
jid6=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5 --job-name=t6 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 6)
jid7=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6 --job-name=t7 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 7)
jid8=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7 --job-name=t8 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 8)
jid9=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8 --job-name=t9 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 9)
jid10=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9 --job-name=t10 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 10)
jid11=$(sbatch --array=1-100%50 --parsable --exclude psycl[10-15] --dependency=afterany:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10 --job-name=t11 ElNet_withPrior_predExpr_200kb_trainGTEx.sh 11)

