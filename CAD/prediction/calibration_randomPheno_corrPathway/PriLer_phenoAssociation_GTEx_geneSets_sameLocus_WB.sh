#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_path_geneSet_sameLocus.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/pheno_path_geneSet_sameLocus.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=2

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/priler_project/Software/model_prediction/

t=Whole_Blood
mkdir -p OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/Association_geneSets_sameLocus_res/

fold=OUTPUT_GTEx/predict_CAD/${t}/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/

# correct for covariates
Rscript ${git_fold}pheno_association_pathscore_largeData_run.R \
	--inputInfoFile ${fold}pathScore_geneSets_sameLocus_info.RData \
	--covDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--phenoDat_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenoMatrix_updateCADHARD.txt \
	--names_file CAD \
	--inputFile ${fold}Pathway_geneSets_sameLocus_scores_splitPath1.RData \
	--outFile ${fold}Association_geneSets_sameLocus_res/pval_pathScore_geneSets_sameLocus_splitPath1_ \
	--cov_corr T \
	--sampleAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt \
	--ncores 2 \
	--phenoAnn_file INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenotypeDescription_CAD.txt \
	--functR ${git_fold}pheno_association_functions.R \
	--path_type geneSets_sameLocus

