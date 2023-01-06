#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/filt_path_JS_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/filt_path_JS_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_clustering/

${git_fold}filter_pathway_jaccard_sim_run.R \
	--pvalresFile ${fold}pval_CAD_pheno_covCorr.RData \
	--thr_js 0.2 \
	--outFold ${fold}

