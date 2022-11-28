#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_association_wiki_metaAnalysis_%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_association_wiki_metaAnalysis_%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}

readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
path_file=/psycl/g/mpsziller/lucia/castom-igex/refData/WikiPathways_2019_Human.RData

name_cohorts=(CG WTCCC LURIC MG German1 German2 German3 German4 German5)

file_res=()
file_pheno=()

for c in ${name_cohorts[@]}
do
	echo ${c}
	file_res+=(OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/${c}/devgeno0.01_testdevgeno0/pval_CAD_pheno_covCorr_customPath_WikiPath2019Human.RData)
	file_pheno+=(INPUT_DATA_GTEx/CAD/Covariates/${c}/phenoMatrix.txt)
done

# correct for covariates
${git_fold}pheno_association_customPath_metaAnalysis_run.R \
	--res_cohorts ${file_res[@]} \
	--phenoDatFile_cohorts ${file_pheno[@]} \
	--phenoName Dx \
	--outFold OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/Meta_Analysis_CAD/ \
	--pathwayStructure_file ${path_file} \
	--geneSetName WikiPath2019Human \
	--cov_corr T \
	--name_cohort ${name_cohorts[@]}







