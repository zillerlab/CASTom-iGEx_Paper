#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/convert_dosage_to_plink_merge_chr%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/convert_dosage_to_plink_merge_chr%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=50G

id_chr=${SLURM_ARRAY_TASK_ID}
split=$(seq 100)

software_fold=/psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/SOFTWARE/
software_fold_v1=/psycl/g/mpsukb/UKBB_hrc_imputation/lucia_scripts/SOFTWARE/plink1.9/
sample_file=/psycl/g/mpsziller/lucia/UKBB/phenotype_data/ukb34217_imp_chr1_v3_s487317.sample
info_file=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/UKBB.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr${id_chr}.txt
cov_file=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix.txt

cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/plink_format/chr${id_chr}/

# create fam file
# FID IID Within-family ID of father Within-family ID of mother sex pheno
awk {'print $1,$1,0,0,1+$13, 1+$14'} ${cov_file} > tmp
tail -n +2 tmp > CAD_UKBB_relativesFilt_whiteBritish.fam
rm tmp

# merge together all the bed files
touch files_list.txt
for i in ${split[@]:1}
do
	cat  <( echo "Genotype_dosage_split${i}_chr${id_chr}.bed Genotype_dosage_split1_chr${id_chr}.bim Genotype_dosage_split${i}_chr${id_chr}.fam" ) >> files_list.txt 
done

### remove samples that withdraw info ####
sample_excl=/psycl/g/mpsziller/lucia/UKBB/phenotype_data/w34217_20200204_sampleTOremove.csv
awk 'NR==FNR{a[$1][$0];next} $0 in a {for (i in a[$0]) print i}' CAD_UKBB_relativesFilt_whiteBritish.fam ${sample_excl} > samples_to_exclude.fam

${software_fold_v1}plink --bfile Genotype_dosage_split1_chr${id_chr} --merge-list files_list.txt --make-bed --remove samples_to_exclude.fam --out Genotype_CAD_UKBB_chr${id_chr}

rm files_list.txt

echo "merge finished"

