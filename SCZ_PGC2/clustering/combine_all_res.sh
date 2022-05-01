#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/combine_all_res.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/combine_all_res.err
#SBATCH -N 1
#SBATCH --mem=20G
#SBATCH -t 48:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/

dat=OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/pval_Dx_pheno_covCorr.RData
tissue_name=DLPC_CMC  

readarray -t tissues < /home/luciat/eQTL_PROJECT/OUTPUT_GTEx/Tissue_PGCgwas

for t in ${tissues[@]}
do
	echo ${t}
	dat+=(OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/pval_Dx_pheno_covCorr.RData)
	tissue_name+=(${t})
done

Rscript RSCRIPTS/combine_all_tissues.R --inputFiles ${dat[@]} --tissues_name ${tissue_name[@]} --info_file OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/phenoInfo_Dx_cohorts.txt --outFold OUTPUT_all/Meta_Analysis_SCZ


