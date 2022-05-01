#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/predExpr_%x_GTEx_t%a.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/predExpr_%x_GTEx_t%a.err
#SBATCH -N 1
#SBATCH --mem=80G
#SBATCH -t 48:00:00


module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/
id_c=$1
readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

git_fold=/home/luciat/castom-igex/Software/model_prediction/

readarray -t tissues < OUTPUT_GTEx/Tissue_PGCgwas
id_t=${SLURM_ARRAY_TASK_ID}
t=$(eval echo "\${tissues[${id_t}-1]}")

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx
cp /home/luciat/eQTL_PROJECT/INPUT_DATA_GTEx/SCZ-PGC/Genotype_data/${c}/Genotype* ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
cp OUTPUT_GTEx/train_GTEx/${t}/200kb/PGC_GWAS_bin1e-2/res* ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
cp OUTPUT_GTEx/train_GTEx/${t}/*mtx ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/
	
${git_fold}PriLer_predictGeneExp_run.R \
	--genoDat_file ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/Genotype_dosage_ \
	--covDat_file INPUT_DATA/Covariates/${c}.covariateMatrix.txt \
	--outFold ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/ \
	--outTrain_fold ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/ \
	--InfoFold ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/ 

cp ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/predictedExpression.txt.gz OUTPUT_GTEx/predict_PGC/${t}/200kb/PGC_GWAS_bin1e-2/${c}/

rm -r ${TMPDIR}/tmp_${id_c}_${id_t}_GTEx/

