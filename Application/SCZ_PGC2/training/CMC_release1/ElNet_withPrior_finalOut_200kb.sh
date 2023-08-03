#!/bin/bash
#SBATCH --output=/ziller/lucia/eQTL_PROJECT_CMC/err_out_fold/%x_200kb_%j.out
#SBATCH --error=/ziller/lucia/eQTL_PROJECT_CMC/err_out_fold/%x_200kb_%j.err


## 18: PGC_gwas_bin
## 2: ERG_Epi
## 3: MRG_Epi 
## 4: SubstantiaNigra_Epi
## 5: AnteriorCaudate_Epi
## 6: MidFrontalLobe_Epi
## 7: AngularGyrus_Epi
## 8: CingulateGyrus_Epi
## 9: HippocampusMiddle_Epi
## 10: InferiorTemporalLobe_Epi
## 11: NE_Epi
## 12: dNPCs_Epi
## 13: FPC_Neuronal_ATAC_R2_Epi
## 14: FPC_Neuronal_ATAC_R4_Epi
## 15: Ctrl_150_allPeaks_cellRanger


Rscript /ziller/lucia/priler_project/Software/model_training/ElNet_withPrior_finalOutput_run.R --covDat_file /ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt  --outFold /ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/ --InfoFold /ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/ --functR /ziller/lucia/priler_project/Software/model_training/ElNet_withPrior_functions_run.R --part1Res_fold /ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/ --part2Res_fold /ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/ --part3Res_fold /ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/ --part4Res_fold /ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/train_All/200kb/ --priorDat_file /ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_SCZ-PGC_SCRIPTS_v2/priorMatrix_ --priorInf 18 2 3 4 5 6 7 8 9 10 11 12 13 14 15 

 

