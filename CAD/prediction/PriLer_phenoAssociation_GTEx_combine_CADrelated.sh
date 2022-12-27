#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_CADrelated_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_CADrelated_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=30G
#SBATCH --cpus-per-task=1


module load R/3.5.3

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/

id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < OUTPUT_GTEx/Tissue_CADgwas
t=$(eval echo "\${tissues[${id_t}-1]}")

name_file=$(awk '{print $1}' INPUT_DATA_GTEx/CAD/Covariates/UKBB/match_cov_pheno_CADrel.txt)
name_file=(${name_file// / })

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/
ref_fold=/psycl/g/mpsziller/lucia/castom-igex/refData/
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/


# correct for covariates
${git_fold}pheno_association_combine_largeData_run.R \
	--names_file ${name_file[@]} \
	--tscoreFold ${fold}Association_tscore_res/ \
	--pathScoreFold_Reactome ${fold}/Association_reactome_res/ \
	--pathScoreFold_GO ${fold}Association_GO_res/ \
	--outFold ${fold} \
	--cov_corr T \
	--phenoAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_PHESANTproc_CADrelatedpheno.txt \
	--reactome_file ${ref_fold}ReactomePathways.gmt \
	--GOterms_file ${ref_fold}GOterm_geneAnnotation_allOntologies.RData



