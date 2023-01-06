#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/filt_path_JS_CMC.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/filt_path_JS_CMC.err
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH -t 120:00:00


module load 2019
module load R/3.5.1-intel-2019b

cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_clustering/

t=DLPC_CMC

fold=OUTPUT_all/Meta_Analysis_SCZ/${t}/

${git_fold}filter_pathway_jaccard_sim_run.R \
	--pvalresFile ${fold}pval_Dx_pheno_covCorr.RData \
	--thr_js 0.2 \
	--outFold ${fold}

