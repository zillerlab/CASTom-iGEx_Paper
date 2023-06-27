#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/combine_pval_UKBB.out
#SBATCH -e /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/combine_pval_UKBB.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=20G


readarray -t name_pheno < /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/name_pheno_clusterSCZ.txt
readarray -t tissues < /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/Meta_Analysis_SCZ/Tissues_PGC_red2

mkdir -p /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/tomove/
fold=/psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/tomove/

for t in ${tissues[@]}
do
	echo ${t}

	if [[ "${t}" == "DLPC_CMC" ]]
	then
	fold_UKBB=(/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/)
	else
	fold_UKBB=(/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/devgeno0.01_testdevgeno0/)
	fi

	mkdir -p ${fold}${t}
	for n in ${name_pheno[@]}
	do
		cp ${fold_UKBB}pval_${n}_pheno_covCorr.RData ${fold}${t}/
	done
	# copy correlation estimation based on UKBB
	cp ${fold_UKBB}correlation_estimate_tscore.RData ${fold}${t}/
done

cd /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/
tar -zcvf tomove.tar.gz tomove
rm -r tomove/
