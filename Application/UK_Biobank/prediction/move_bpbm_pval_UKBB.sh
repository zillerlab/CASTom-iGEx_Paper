#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/combine_pval_UKBB.out
#SBATCH -e /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/combine_pval_UKBB.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=20G


name_pheno=(Blood_pressure Body_size_measures)

mkdir -p /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/tomove_BPBM/
fold=/psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/tomove_BPBM/

fold_UKBB=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_CMC/predict_UKBB/200kb/devgeno0.01_testdevgeno0/
mkdir -p ${fold}DLPC_CMC
for n in ${name_pheno[@]}
do
	cp ${fold_UKBB}pval_${n}_pheno_covCorr.RData ${fold}DLPC_CMC/
done
	
cd /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/
tar -zcvf tomove_BPBM.tar.gz tomove_BPBM
rm -r tomove_BPBM/
