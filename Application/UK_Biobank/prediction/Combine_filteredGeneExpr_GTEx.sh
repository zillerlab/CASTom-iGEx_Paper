#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/combinePredExpr_GTEx_filtGenes_%x.out
#SBATCH -e /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/err_out_fold/combinePredExpr_GTEx_filtGenes_%x.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=40G

id_t=$1

readarray -t tissues < /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/Tissue_noGWAS
t=$(eval echo "\${tissues[${id_t}-1]}")

cd /psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_UKBB/${t}/200kb/noGWAS/
gene_info=/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/OUTPUT_GTEx/train_GTEx/${t}/200kb/noGWAS/resPrior_regEval_allchr.txt
testdevgeno=0
devgeno=0.01

# create gene list to keep 
# head -1 ${gene_info} | tr '\t' '\n' | cat -n | grep "test_dev_geno"
# 17 --> test_dev_geno, 25 --> dev_geno, 8 --> ensembl_gene_id, 29 --> cor_pval (last value)

awk '{print $8,$25,$17}' ${gene_info} > geneList_tmp
# print gene names to remove
awk -v tdg=${testdevgeno} -v dg=${devgeno} '{ if(($2 == "NA") || ($3 == "NA") || ($3 < tdg) || ($2 < dg)) { print } }' geneList_tmp > rm_geneList

# first split, keep gene info
zcat split1_predictedExpression.txt.gz > tmp.txt
awk 'NR==FNR{a[$1];next} !($8 in a)' rm_geneList tmp.txt > devgeno${devgeno}_testdevgeno${testdevgeno}/split1_predictedExpression_filt.txt
rm tmp.txt
cp devgeno${devgeno}_testdevgeno${testdevgeno}/split1_predictedExpression_filt.txt devgeno${devgeno}_testdevgeno${testdevgeno}/predictedExpression_filt.txt

# from each split file remove the gene list
for i in $(seq 2 1 100)
do
	
	zcat split${i}_predictedExpression.txt.gz > tmp.txt
	awk 'NR==FNR{a[$1];next} !($8 in a)' rm_geneList tmp.txt > devgeno${devgeno}_testdevgeno${testdevgeno}/split${i}_predictedExpression_filt.txt
	rm tmp.txt	
	cut --complement -f1-29 devgeno${devgeno}_testdevgeno${testdevgeno}/split${i}_predictedExpression_filt.txt > devgeno${devgeno}_testdevgeno${testdevgeno}/split${i}_predictedExpression_filt_nogene.txt
	paste -d "\t" devgeno${devgeno}_testdevgeno${testdevgeno}/predictedExpression_filt.txt  devgeno${devgeno}_testdevgeno${testdevgeno}/split${i}_predictedExpression_filt_nogene.txt > devgeno${devgeno}_testdevgeno${testdevgeno}/tmp_tot
	mv devgeno${devgeno}_testdevgeno${testdevgeno}/tmp_tot devgeno${devgeno}_testdevgeno${testdevgeno}/predictedExpression_filt.txt
	rm devgeno${devgeno}_testdevgeno${testdevgeno}/split${i}_predictedExpression_filt_nogene.txt

done

gzip devgeno${devgeno}_testdevgeno${testdevgeno}/predictedExpression_filt.txt


