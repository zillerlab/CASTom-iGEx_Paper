#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/originalRNA_tscore_pathscore.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_SHIP/err_out_fold/originalRNA_tscore_pathscore.err
#SBATCH --time=1-0
#SBATCH --nodes=1
#SBATCH --mem=10G

R_LIBS_USER=/u/luciat/R/x86_64-pc-linux-gnu-library/4.0/
module load r_anaconda/4.0.3

### convert gene expression in the correct format ###
# Rscript preproc_original_gene_exp.R

### get Tscore and pathway scores ###
cd /psycl/g/mpsziller/lucia/CAD_SHIP/

git_fold=/psycl/g/mpsziller/lucia/castom_cad_scz/Application/CAD/replication_SHIP-Trend/
git_ref=/psycl/g/mpsziller/lucia/castom-igex/refData/

fold=GENE_EXPR/
input_file=${fold}/Filtered_SHIP-TREND_GX_plate01-14_QuantileNormalized.log2Transformd-zz_transposed-resid-SHIP_2022_27_filtered_WB_Liver.txt

${git_fold}Modified_Tscore_PathScore_diff_run.R \
	--input_file ${input_file} \
	--reactome_file ${git_ref}ReactomePathways.gmt \
	--GOterms_file ${git_ref}GOterm_geneAnnotation_allOntologies.RData \
	--covDat_file Results/PriLer/SHIP-TREND_gPC_SHIP_2022_27_withSex.txt \
	--nFolds 40 \
	--outFold ${fold}filtered_WB_Liver_ \
	--originalRNA T
