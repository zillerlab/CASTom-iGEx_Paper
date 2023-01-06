#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/hypgeom_test_pathways.out
#SBATCH -e /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/err_out_fold/hypgeom_test_pathways.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom_cad_scz/R/

fold=OUTPUT_GTEx/predict_CAD/AllTissues/200kb/CAD_GWAS_bin5e-2/UKBB/

# GO
Rscript ${git_fold}hypergeometric_pathwayEnrich_TWASgenes_run.R \
	--outFold ${fold} \
	--tscore_file ${fold}tscore_pval_CAD_HARD_covCorr.txt \
	--pathScore_file ${fold}path_GO_pval_CAD_HARD_covCorr_filt.txt \
	--type_pathway path_GO
echo "GO completed"

# reactome
Rscript ${git_fold}hypergeometric_pathwayEnrich_TWASgenes_run.R \
        --outFold ${fold} \
        --tscore_file ${fold}tscore_pval_CAD_HARD_covCorr.txt \
        --pathScore_file ${fold}path_Reactome_pval_CAD_HARD_covCorr_filt.txt \
        --type_pathway path_Reactome
echo "Reactome completed"

# wiki
Rscript ${git_fold}hypergeometric_pathwayEnrich_TWASgenes_run.R \
        --outFold ${fold} \
        --tscore_file ${fold}tscore_pval_CAD_HARD_covCorr.txt \
        --pathScore_file ${fold}path_WikiPath2019Human_pval_CAD_HARD_covCorr_filt.txt \
        --type_pathway path_WikiPath2019Human
echo "Wiki completed"

