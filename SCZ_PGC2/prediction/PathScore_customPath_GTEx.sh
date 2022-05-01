#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/custom_pathDiff_%x_c%a.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/custom_pathDiff_%x_c%a.err
#SBATCH -N 1
#SBATCH --mem=20G
#SBATCH -t 48:00:00

module load pre2019 2019
module load R

cd /home/luciat/eQTL_PROJECT/

id_c=${SLURM_ARRAY_TASK_ID}
readarray -t cohorts < INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")

git_fold=/home/luciat/castom-igex/Software/model_prediction/
file_path_name=$1
path_name=$2
tissue=$3

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_${tissue}/
cp /home/luciat/priler_project/refData/${file_path_name} ${TMPDIR}/tmp_${id_c}_${tissue}/
cp OUTPUT_GTEx/predict_PGC/${tissue}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/predictedTscores.txt ${TMPDIR}/tmp_${id_c}_${tissue}/

${git_fold}pathScore_customGeneList_run.R \
	--sampleAnn_file INPUT_DATA/Covariates/${c}.covariateMatrix_old.txt \
	--pathwayStruct_file ${TMPDIR}/tmp_${id_c}_${tissue}/${file_path_name} \
	--tscore_file ${TMPDIR}/tmp_${id_c}_${tissue}/predictedTscores.txt \
	--outFold ${TMPDIR}/tmp_${id_c}_${tissue}/ \
	--geneSetName ${path_name} 

cp ${TMPDIR}/tmp_${id_c}_${tissue}/Pathway* OUTPUT_GTEx/predict_PGC/${tissue}/200kb/PGC_GWAS_bin1e-2/${c}/devgeno0.01_testdevgeno0/

rm -r ${TMPDIR}/tmp_${id_c}_${tissue}/
