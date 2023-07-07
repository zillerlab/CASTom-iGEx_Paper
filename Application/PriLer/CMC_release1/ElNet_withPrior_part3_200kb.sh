#!/bin/bash
#SBATCH --output=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.out
#SBATCH --error=/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/err_out_fold/%x_200kb_%j.err


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


type_name=$1
ncores=$2
f=/psycl/g/mpsziller/lucia/
git_fold=${f}castom-igex/Software/model_training/

${git_fold}PriLer_part3_run.R  --covDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/train_${type_name}/covariateMatrix_${type_name}.txt --genoDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/Genotype_dosage_ --geneExp_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/RNAseq_data/EXCLUDE_ANCESTRY_SVA/RNAseq_filt.txt --ncores ${ncores} --outFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/train_${type_name}/200kb/ --InfoFold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/ --functR ${git_fold}PriLer_functions.R --part2Res_fold /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/train_${type_name}/200kb/ --priorDat_file /psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/priorMatrix_ --priorInf 18 2 3 4 5 6 7 8 9 10 11 12 13 14 15 

 

