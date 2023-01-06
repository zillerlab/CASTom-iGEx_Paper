#!/bin/bash
#SBATCH -o /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/hypgeom_test_pathways.out
#SBATCH -e /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/err_out_fold/hypgeom_test_pathways.err
#SBATCH --time=7-0
#SBATCH --nodes=1
#SBATCH --mem=10G

module load R/3.5.3
cd /psycl/g/mpsziller/lucia/SCZ_PGC/eQTL_PROJECT/
git_fold=/psycl/g/mpsziller/lucia/castom_cad_scz/R/

fold=Meta_Analysis_SCZ/OUTPUT_all/

# GO
Rscript ${git_fold}hypergeometric_pathwayEnrich_TWASgenes_run.R \
	--outFold ${fold} \
	--tscore_file ${fold}tscore_pval_SCZ_covCorr.txt \
	--pathScore_file ${fold}path_GO_pval_SCZ_covCorr_filt.txt \
	--type_pathway path_GO
echo "GO completed"

# reactome
Rscript ${git_fold}hypergeometric_pathwayEnrich_TWASgenes_run.R \
        --outFold ${fold} \
        --tscore_file ${fold}tscore_pval_SCZ_covCorr.txt \
        --pathScore_file ${fold}path_Reactome_pval_SCZ_covCorr_filt.txt \
        --type_pathway path_Reactome
echo "Reactome completed"

# wiki
Rscript ${git_fold}hypergeometric_pathwayEnrich_TWASgenes_run.R \
        --outFold ${fold} \
        --tscore_file ${fold}tscore_pval_SCZ_covCorr.txt \
        --pathScore_file ${fold}customPath_WikiPath2019Human_pval_SCZ_covCorr_filt.txt \
        --type_pathway path_WikiPath2019Human
echo "Wiki completed"

# CMC
Rscript ${git_fold}hypergeometric_pathwayEnrich_TWASgenes_run.R \
        --outFold ${fold} \
        --tscore_file ${fold}tscore_pval_SCZ_covCorr.txt \
        --pathScore_file ${fold}customPath_CMC_GeneSets_pval_SCZ_covCorr_filt.txt \
        --type_pathway path_CMC_GeneSets
echo "CMC_GeneSets completed"

