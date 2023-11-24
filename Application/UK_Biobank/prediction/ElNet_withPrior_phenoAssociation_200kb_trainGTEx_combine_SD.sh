#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_t%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_t%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=30G
#SBATCH --cpus-per-task=1


id_t=${SLURM_ARRAY_TASK_ID}
readarray -t tissues < /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/Tissue_noGWAS
t=$(eval echo "\${tissues[${id_t}-1]}")


module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
git_fold_ref=/psycl/g/mpsziller/lucia/castom-igex/refData/

name_file=$(awk '{print $1}' INPUT_DATA/Covariates/match_cov_pheno_SchunkertApp.txt)
name_file=(${name_file// / })

# correct for covariates
${git_fold}pheno_association_combine_largeData_run.R \
    --names_file ${name_file[@]} \
    --tscoreFold OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/Association_tscore_res/ \
    --pathScoreFold_Reactome OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/Association_reactome_res/ \
    --pathScoreFold_GO OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/Association_GO_res/ \
    --outFold OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/ \
    --cov_corr T \
    --phenoAnn_file INPUT_DATA/Covariates/phenotypeDescription_PHESANTproc.txt \
    --reactome_file ${git_fold_ref}ReactomePathways.gmt \
    --GOterms_file ${git_fold_ref}GOterm_geneAnnotation_allOntologies.RData


