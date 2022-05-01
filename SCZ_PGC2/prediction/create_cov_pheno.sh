#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/create_cov_pheno_cohort%a.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/create_cov_pheno_cohort%a.err
#SBATCH -N 1
#SBATCH --mem=5G
#SBATCH -t 5:00:00


module load pre2019 2019
module load R

id_c=${SLURM_ARRAY_TASK_ID}

readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

Rscript /home/luciat/eQTL_PROJECT/RSCRIPTS/create_cov_pheno_run.R --cohort_name ${c} --mdsFile //home/pgcdac/DWFV2CJb8Piv_0116_pgc_data/scz/wave2/v1/prune.bfile.cobg.PGC_SCZ49.sh2.menv.mds_cov --sampleFile //home/pgcdac/DWFV2CJb8Piv_0116_pgc_data/scz/wave2/v1/${c}-qc.fam --outFold /home/luciat/eQTL_PROJECT/INPUT_DATA/Covariates/
