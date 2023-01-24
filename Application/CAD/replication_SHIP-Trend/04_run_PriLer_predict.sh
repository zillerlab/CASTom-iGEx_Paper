#!/bin/sh

for cohort in SHIP-0 SHIP-TREND
do

 for trait in Whole_Blood Liver
 do

  echo Running ${trait} for ${cohort} ...

  outfolder=CAD_shared_SHIP/SCRIPTS/output/prediction/${cohort}/${trait}
  mkdir -p ${outfolder}
  git_fold=/psycl/g/mpsziller/lucia/castom-igex/Software/model_prediction/

  ${git_fold}PriLer_predictGeneExp_smallerVariantSet_run.R \
  --outTrain_fold=CAD_shared_SHIP/PRILER_MODELS/${trait}/ \
  --InfoFold=CAD_shared_SHIP/PRILER_MODELS/${trait}/ \
  --genoDat_file=CAD_shared_SHIP/SCRIPTS/output/${cohort}/Genotype_dosage_ \
  --outFold=${outfolder}/ \
  --genoInfo_file=CAD_shared_SHIP/SCRIPTS/output/${cohort}/${cohort}.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_ \
  --genoInfo_model_file=CAD_shared_SHIP/GENOTYPE/Genotype_VariantsInfo_GTEx-PGCgwas-CADgwas-CADall-UKBB_ \
  --covDat_file=CAD_shared_SHIP/SCRIPTS/local/${cohort}.covar

 done
done

