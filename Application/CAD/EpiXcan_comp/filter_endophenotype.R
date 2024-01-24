# filter endophenotype results
options(stringsAsFactors=F)
options(max.print=1000)
library(dplyr)
library(tidyverse)

cl_fold <- "/scratch/tmp/dolgalev/castom-igex-revision/epixcan/results/ukbb/CAD_HARD_clustering/update_corrPCs/"

class_to_keep <- c("Blood_biochemistry", "Blood_count", 
                   "Blood_count_ratio", "Blood_pressure", 
                   "Body_size_measures", "Impedance_measures", 
                   "Arterial_stiffness", "Hand_grip_strength", 
                   "Early_life_factors", "Family_history",
                   "Height_derived", "ICD9-10_OPCS4")
# save
#write.table(data.frame(id = class_to_keep), paste0(out_fold, "pheno_class_to_keep.txt"), sep="\t", row.names=F, quote=F, col.names=F)
# the excluded class is : Alcohol  Diet  Medication  Medications  Physical_activity   Sleep    Smoking

# load results
file_cases <- sprintf("%stscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM_combined.txt", cl_fold)

filter_endo <- function(file_endo, class_to_keep, outFold){

    endo_res <- read.delim(file_endo, header=T, sep="\t", stringsAsFactors=F)
    # remove NA
    endo_res <- endo_res %>% drop_na(beta)
    endo_keep <- endo_res %>%
    filter(pheno_type %in% class_to_keep) %>%
    group_by(comp) %>%
    mutate(pval_corr = p.adjust(pvalue, method="BH")) %>%
    select(-pval_corr_overall) %>%
    ungroup()

    endo_additional <- endo_res %>% 
    filter(!pheno_type %in% class_to_keep) %>%
    group_by(comp) %>%
    mutate(pval_corr = p.adjust(pvalue, method="BH")) %>%
    select(-pval_corr_overall) %>%
    ungroup()

    # save
    tmp_name <- strsplit(file_endo, split=".txt")[[1]][1]
    tmp_name <- strsplit(tmp_name, split="/")[[1]][length(strsplit(tmp_name, split="/")[[1]])]
    print(tmp_name)
    write.table(endo_keep, paste0(outFold, tmp_name, "_keepPhenoClass.txt"), sep="\t", row.names=F, quote=F, col.names=T)
    write.table(endo_additional, paste0(outFold, tmp_name, "_extraPhenoClass.txt"), sep="\t", row.names=F, quote=F, col.names=T)

    return(list(keep = endo_keep, extra = endo_additional))
}

endo_cases <- filter_endo(file_cases, class_to_keep, sprintf("%s", cl_fold))
