#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_CMC.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/phenoAssociation_combine_CMC.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=50G
#SBATCH --cpus-per-task=1


module load R
cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/

###### PHESANT processed pehnotypes ######
name_file=$(awk '{print $1}' INPUT_DATA/Covariates/match_cov_pheno.txt)
name_file=(${name_file// / })
git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/
git_fold_ref=/psycl/g/mpsziller/lucia/castom-igex/refData/

# correct for covariates
${git_fold}pheno_association_combine_largeData_run.R --names_file ${name_file[@]} --tscoreFold OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_tscore_res/ --pathScoreFold_Reactome OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_reactome_res/ --pathScoreFold_GO OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_GO_res/ --outFold OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/ --cov_corr T --phenoAnn_file INPUT_DATA/Covariates/phenotypeDescription_PHESANTproc.txt --reactome_file ${git_fold_ref}ReactomePathways.gmt --GOterms_file ${git_fold_ref}GOterm_geneAnnotation_allOntologies.RData

##### manually curated phenotypes #####
# correct for covariates
${git_fold}pheno_association_combine_largeData_run.R --names_file mixedpheno_Psychiatric ICD9_Psychiatric ICD10_Psychiatric --tscoreFold OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_tscore_res/ --pathScoreFold_Reactome OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_reactome_res/ --pathScoreFold_GO OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/Association_GO_res/ --outFold OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/ --cov_corr T --phenoAnn_file INPUT_DATA/Covariates/phenotypeDescription_manualproc_ICD9-10_mixedpheno_Psychiatric.txt --reactome_file ${git_fold_ref}ReactomePathways.gmt --GOterms_file ${git_fold_ref}GOterm_geneAnnotation_allOntologies.RData



