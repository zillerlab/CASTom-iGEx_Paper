#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/combine_pval_UKBB.out
#SBATCH -e /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/combine_pval_UKBB.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=20G


name_pheno=Blood_count_ratio
readarray -t tissues < /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/Meta_Analysis_SCZ/Tissues_PGC_red2

mkdir -p /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/tomove_new/
fold=/psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/tomove_new/

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
	
done

cd /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/
tar -zcvf tomove_new.tar.gz tomove_new
rm -r tomove_new/
