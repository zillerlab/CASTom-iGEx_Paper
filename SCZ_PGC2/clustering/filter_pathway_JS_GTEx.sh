#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/filt_path_JS_t%a.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/filt_path_JS_t%a.err
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH -t 120:00:00


module load 2019
module load R/3.5.1-intel-2019b

cd /home/luciat/eQTL_PROJECT/
git_fold=/home/luciat/castom-igex/Software/model_clustering/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_PGCgwas_red

t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_all/Meta_Analysis_SCZ/${t}/

Rscript ${git_fold}filter_pathway_jaccard_sim_run.R \
	--pvalOut ${fold}pval_Dx_pheno_covCorr.RData \
	--thr_js 0.2 \
	--outFold ${fold}

