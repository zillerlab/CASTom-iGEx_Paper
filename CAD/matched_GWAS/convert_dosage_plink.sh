#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/convert_dosage_to_plink_chr%a.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/convert_dosage_to_plink_chr%a.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

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

for i in ${split[@]}
do

	echo "###################### ${i} #####################"

	input_file=/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Genotyping_data/UKBB/Genotype_dosage_split${i}_chr${id_chr}_matrix.txt.gz	
	
	# put file in the correct format

	# put in the correct format .gz file, filter samples
	zcat ${input_file} | head -1 | tr -s '\t'  '\n' > header_samples
	awk 'NR==FNR{a[$1][$0];next} $0 in a {for (i in a[$0]) print i}' CAD_UKBB_relativesFilt_whiteBritish.fam header_samples > filt_samples.fam 

	# obtain .fam file for current samples, filter based on the covariate file
	awk 'NR==FNR{a[$1][$0];next} $0 in a {for (i in a[$0]) print i}' ${sample_file} header_samples > old.fam 
	awk '{print $1,$2,$3,$3,$4,-9}' old.fam > original.fam
	rm old.fam

	# create correct snp info
	# format: CHR RSID POS A1(ALT) A2(REF)
	awk '{print $3,$6,$5}' ${info_file} | tail -n +2 > tmp2
	awk '{print $1,$3,0,$4}' ${info_file} | tail -n +2 > Genotype_dosage_split${i}_chr${id_chr}.map
	sed -e '1i\RSID A1 A2' tmp2 > snp_info
	rm tmp2

	zcat ${input_file} | tail -n +2 | tr '\t' ' ' > tmp
	paste -d "_" header_samples header_samples > new_header

	# attach new header
	cut -f1 new_header | paste -s -d ' ' > new_header2
	cat new_header2 tmp > tmp2
	paste -d " " snp_info tmp2 > Genotype_dosage_split${i}_chr${id_chr}.txt
	rm header_samples new_header new_header2 snp_info tmp tmp2

	
	# convert to plink
	${software_fold}plink2 --import-dosage Genotype_dosage_split${i}_chr${id_chr}.txt format=1 id-delim=_ --map Genotype_dosage_split${i}_chr${id_chr}.map --fam original.fam --keep filt_samples.fam --make-bed --out Genotype_dosage_split${i}_chr${id_chr}

	# add case control info to the new fam file (match with filt_samples.fam)
	awk 'NR==FNR{o[FNR]=$1; next} {t[$1]=$0} END{for(x=1; x<=FNR; x++){y=o[x]; print t[y]}}' Genotype_dosage_split${i}_chr${id_chr}.fam filt_samples.fam > new_split${i}_chr${id_chr}.fam

	diff <( awk '{print $1}' new_split${i}_chr${id_chr}.fam ) <( awk '{print $1}' Genotype_dosage_split${i}_chr${id_chr}.fam ) > diff_file
	if [ -s "diff_file" ]
	then 
		echo "error on .fam file filtering" 
		mv  diff_file diff_file_split${i}_chr${id_chr}
	else
		mv new_split${i}_chr${id_chr}.fam Genotype_dosage_split${i}_chr${id_chr}.fam
		rm diff_file
	fi
	
	rm original.fam filt_samples.fam Genotype_dosage_split${i}_chr${id_chr}.map Genotype_dosage_split${i}_chr${id_chr}.txt
	
done
	
echo "split conversion finished"

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








