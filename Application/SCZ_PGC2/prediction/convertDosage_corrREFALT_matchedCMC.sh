#!/bin/bash
#SBATCH -o /home/luciat/eQTL_PROJECT/err_out_fold/convert_dosage_CMC_%x_chr%a.out
#SBATCH -e /home/luciat/eQTL_PROJECT/err_out_fold/convert_dosage_CMC_%x_chr%a.err
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH -t 5:00:00


module load pre2019 2019
module load python

id_chr=${SLURM_ARRAY_TASK_ID}
id_c=$1
converter=/home/luciat/eQTL_PROJECT/PYTHON_SCRIPTS/lucia_matrix_conversion.py

readarray -t cohorts < /home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names
c=$(eval echo "\${cohorts[${id_c}-1]}")
input_dir=//home/pgcdac/DWFV2CJb8Piv_0116_pgc_data/scz/wave2/v1/dasuqc1_${c}-qc.ch.fl/qc1
output_dir=/home/luciat/eQTL_PROJECT/INPUT_DATA_CMC/SCZ-PGC/Genotype_data/
region_index=$(tail +2 /home/pgcdac/DWFV2CJb8Piv_0116_pgc_data/scz/wave2/v1/reference_info)

# copy needed file on TMPDIR
mkdir -p ${TMPDIR}/tmp_${id_c}_${id_chr}
cd ${TMPDIR}/tmp_${id_c}_${id_chr}/
touch ${c}_chr${id_chr}_matrixeQTL.geno

# extract variants to keep and correct ref and alt
cp ${output_dir}/${c}/${c}.Genotype_VariantsInfo_matchedSCZ-PGCall-CMC_chr${id_chr}.txt.gz ./
zcat ${c}.Genotype_VariantsInfo_matchedSCZ-PGCall-CMC_chr${id_chr}.txt.gz | awk  'FNR>1 {print $2}' > var_tokeep_chr${id_chr}
zcat ${c}.Genotype_VariantsInfo_matchedSCZ-PGCall-CMC_chr${id_chr}.txt.gz | awk  'FNR>1 {print $2,$4}' > chr${id_chr}_ref.txt
	
for i in ${region_index[@]}
do
	if [[ ${i} == *"chr${id_chr}_"* ]]
	then
		echo ${i}
		cp ${input_dir}/dos_${c}-qc.ch.fl.${i}.out.dosage.map ./
		cp ${input_dir}/dos_${c}-qc.ch.fl.${i}.out.dosage.gz ./
		cp ${input_dir}/dos_${c}-qc.ch.fl.${i}.out.dosage.fam ./dos_${c}-qc.ch.fl.out.dosage.fam

		# check if there is intersection
		awk '{print $2}' dos_${c}-qc.ch.fl.${i}.out.dosage.map > original_var_${i}
		awk 'NR==FNR{c[$1$1]++;next};c[$1$1] > 0' original_var_${i} var_tokeep_chr${id_chr} > common_var_${i}
		if [ -s common_var_${i} ]
		then
			# use plink to correct wrong ref/alt annotations
			/home/luciat/Software/plink2 --import-dosage dos_${c}-qc.ch.fl.${i}.out.dosage.gz 'format=2' --psam dos_${c}-qc.ch.fl.out.dosage.fam --map dos_${c}-qc.ch.fl.${i}.out.dosage.map --ref-allele force chr${id_chr}_ref.txt 2 1 --export oxford ref-first --extract var_tokeep_chr${id_chr} --out tmp_${c}_${i}

			# convert to dosage format
			python $converter tmp_${c}_${i} 
			cat tmp_${c}_${i}_matrixeQTL.geno >> ${c}_chr${id_chr}_matrixeQTL.geno
			rm tmp_${c}_${i}_matrixeQTL.geno tmp_${c}_${i}.gen tmp_${c}_${i}.sample tmp_${c}_${i}.log common_var_${i} original_var_${i}
		else
			echo "no intersection in ${i}"
		fi
	fi
done

# check first column identical to info file, then delete it
diff <(cat var_tokeep_chr${id_chr} )  <( awk  '{print $1}' ${c}_chr${id_chr}_matrixeQTL.geno ) > diff_res_${id_chr}
if [ -s diff_res_${id_chr} ]
then 
	echo ERROR: chr${id_chr} transformation different positions
else		
	# transofrm to dosage .txt
	awk  'BEGIN {OFS="_"}; {print $1,$2}' dos_${c}-qc.ch.fl.out.dosage.fam | paste -s > samples_chr${id_chr} 
	cat <( cat samples_chr${id_chr} ) <( cut -f1 --complement ${c}_chr${id_chr}_matrixeQTL.geno ) > Genotype_dosage_chr${id_chr}_matrix.txt
	gzip Genotype_dosage_chr${id_chr}_matrix.txt
	
	cp Genotype_dosage_chr${id_chr}_matrix.txt.gz ${output_dir}/${c}/Genotype_dosage_chr${id_chr}_matrix.txt.gz 

fi

rm -r ${TMPDIR}/tmp_${id_c}_${id_chr}




