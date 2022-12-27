#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_BCratio_tscore_%x_split%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_BCratio_tscore_%x_split%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=10

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

id_t=$1
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
pheno_fold=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/
in_fold=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/

# correct for covariates
${git_fold}pheno_association_tscore_largeData_run.R \
	--split_tot 100 \
	--inputInfoFile ${fold}tscore_info.RData \
	--covDat_file ${in_fold}covariateMatrix_withMedication.txt \
	--phenoDat_file ${pheno_fold}phenotypeMatrix_Blood_count_ratio.txt \
	--names_file Blood_count_ratio_withMed \
	--inputFile ${fold}predictedTscores_splitGenes${SLURM_ARRAY_TASK_ID}.RData \
	--outFile ${fold}Association_tscore_res/pval_tscore_splitGene${SLURM_ARRAY_TASK_ID}_ \
	--split_gene_id ${SLURM_ARRAY_TASK_ID} \
	--cov_corr T \
	--sampleAnn_file ${in_fold}covariateMatrix_latestW.txt \
	--ncores 10 \
	--phenoAnn_file ${pheno_fold}phenotypeDescription_ratioBC_PHESANTproc.txt \
	--functR ${git_fold}pheno_association_functions.R  

