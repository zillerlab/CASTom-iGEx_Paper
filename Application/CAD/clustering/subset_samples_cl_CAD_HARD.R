# define subset of samples to be used for clustering

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(coin))

parser <- ArgumentParser(description="clustering using PG method")
parser$add_argument("--fold1", type = "character", help = "working directory")
parser$add_argument("--fold2", type = "character", help = "additional blood count ratio folder")

args <- parser$parse_args()
fold1 <- args$fold1
fold2 <- args$fold2

###############################################################################
# fold1 <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/'
# fold2 <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/'
###############################################################################

# setwd(fold)

phenoInfo <- fread(sprintf('%sphenotypeDescription_PHESANTproc_CADrelatedpheno_annotated.txt', fold1), h=T, stringsAsFactors=F, data.table=F) 
phenoICDInfo <- fread(sprintf('%sphenotypeDescription_manualproc_ICD9-10_OPCS4.txt', fold1), h=T, stringsAsFactors=F, data.table=F) 

sampleAnn <- fread(sprintf('%scovariateMatrix_latestW_202202.txt', fold1), h=T, stringsAsFactors=F, data.table=F) # use to match the other files
phenoDat <- fread(sprintf('%sphenoMatrix.txt', fold1), h=T, stringsAsFactors=F, data.table = F)
sampleAnn_tot <- fread(sprintf('%scovariatesMatrix_batchInfo.txt', fold1), h=T, stringsAsFactors=F, data.table=F)

sampleAnn_tot <- sampleAnn_tot[match(sampleAnn$Individual_ID, sampleAnn_tot$Individual_ID),]
phenoDat <- phenoDat[match(sampleAnn$Individual_ID, phenoDat$Individual_ID),]

# load phenotypeMatrices
pheno_names <- c('Early_life_factors','Blood_biochemistry', 'Blood_count', 'Blood_pressure', 'Body_size_measures', 'Impedance_measures', 'Family_history', 'Smoking', 
                 'Sleep', 'Alcohol','Arterial_stiffness', 'Diet', 'Hand_grip_strength', 'Physical_activity', 
                 'ICD10_Anaemia', 'ICD10_Circulatory_system', 'ICD10_Respiratory_system', 'ICD10_Endocrine', 'Medications', 'Medication')
phenoDat_endo <- list()
for(i in 1:length(pheno_names)){
  print(pheno_names[i])
  tmp <- fread(sprintf('%sphenotypeMatrix_%s.txt', fold1, pheno_names[i]), h=T, stringsAsFactors=F, data.table = F)
  common_s <- intersect(sampleAnn$Individual_ID, tmp$Individual_ID)
  tmp <- tmp[match(common_s, tmp$Individual_ID),]
  rownames(tmp) <- tmp$Individual_ID
  tmp <- tmp[, -1, drop=F]
  phenoDat_endo[[i]] <- tmp
}

pheno_names_2 <- c( 'Blood_count_ratio', 'Height_derived')
for(i in 1:length(pheno_names_2)){
  
  tmp <- fread(sprintf('%sphenotypeMatrix_%s.txt', fold2, pheno_names_2[i]), h=T, stringsAsFactors=F, data.table = F)
  common_s <- intersect(sampleAnn$Individual_ID, tmp$Individual_ID)
  tmp <- tmp[match(common_s, tmp$Individual_ID),]
  rownames(tmp) <- tmp$Individual_ID
  tmp <- tmp[, -1, drop=F]
  phenoDat_endo[[length(pheno_names)+i]] <- tmp
}
pheno_names <- c(pheno_names, pheno_names_2)

# put together brc and total pheno info
phenoInfo <- phenoInfo[, !colnames(phenoInfo) %in% c('nsamples_CAD_SOFT_0', 'nsamples_CAD_SOFT_1', 'nsamples_CAD_SOFT_0_T',
                                                    'nsamples_CAD_SOFT_1_T')]
vect_names <- c('ratioBC', 'HeightDer')
for(i in 1:length(vect_names)){
  pheno_desc <- fread(sprintf('%sphenotypeDescription_%s_PHESANTproc.txt', fold2, vect_names[i]), 
                      h=T, stringsAsFactors=F, data.table=F)
  pheno_desc <- pheno_desc[!pheno_desc$pheno_id %in% c('userId', 'age', 'sex'),]
  pheno_desc$pheno_type <- pheno_names_2[i]
  pheno_desc$keep <- T
  phenoInfo <- rbind(phenoInfo, pheno_desc)
}

phenoInfo <- phenoInfo[!duplicated(phenoInfo$pheno_id),]  

if(!all(apply(sapply(phenoDat_endo, function(x) rownames(x)), 1, function(y) length(unique(y)) == 1))){stop('wrong sample annotation')}
phenoDat_endo <- do.call(cbind, phenoDat_endo)
identical(rownames(phenoDat_endo), sampleAnn$Individual_ID)

cases_id <- phenoDat$Individual_ID[phenoDat$CAD_HARD == 1]
controls_id <- phenoDat$Individual_ID[phenoDat$CAD_SOFT != 1]

# remove from controls samples with family history
phenoInfo_rm <- subset(phenoInfo, pheno_type %in% 'Family_history' & FieldID %in% c('20107', '20110', '20111') & Coding_meaning %in% c('Heart disease', 'Stroke'))
phenoDat_fam <- phenoDat_endo[, colnames(phenoDat_endo) %in% phenoInfo_rm$pheno_id]
tmp <- phenoDat_fam[rownames(phenoDat_fam) %in% controls_id, ]
rm_samples <-  names(which(rowSums(tmp, na.rm = T)>0))
controls_id <- controls_id[!controls_id %in% rm_samples]

#####################################################################################
phenoDat_endo_cases <- phenoDat_endo[rownames(phenoDat_endo) %in% cases_id, ]
# filter controls
phenoDat_endo_controls <- phenoDat_endo[rownames(phenoDat_endo) %in% controls_id, ]

# use same numbers and match Gender/Age
age_set <- sort(unique(sampleAnn_tot$Age[sampleAnn_tot$Individual_ID %in% cases_id]))
id <- c()
for(i in 1:length(age_set)){
  
  set.seed(9+i)
  print(i)
  # female
  if(length(sampleAnn_tot$Individual_ID[sampleAnn_tot$Individual_ID %in% controls_id & sampleAnn_tot$Age == age_set[i] & sampleAnn_tot$Gender == 1])>0){
    id <- c(id, sample(sampleAnn_tot$Individual_ID[sampleAnn_tot$Individual_ID %in% controls_id & sampleAnn_tot$Age == age_set[i] & sampleAnn_tot$Gender == 1], 
                       length(which(sampleAnn_tot$Individual_ID %in% cases_id & sampleAnn_tot$Age == age_set[i] & sampleAnn_tot$Gender == 1)), replace = F))
  }
  # male
  if(length(sampleAnn_tot$Individual_ID[sampleAnn_tot$Individual_ID %in% controls_id & sampleAnn_tot$Age == age_set[i] & sampleAnn_tot$Gender == 0])>0){
    id <- c(id, sample(sampleAnn_tot$Individual_ID[sampleAnn_tot$Individual_ID %in% controls_id & sampleAnn_tot$Age == age_set[i] & sampleAnn_tot$Gender == 0], 
                       length(which(sampleAnn_tot$Individual_ID %in% cases_id & sampleAnn_tot$Age == age_set[i] & sampleAnn_tot$Gender == 0)), replace = F))
  }
}

controls_keep_match <- id

final_id <- c(cases_id, controls_keep_match)
sampleAnn_tot_fin <- sampleAnn_tot[match(final_id, sampleAnn_tot$Individual_ID), ]
sampleAnn_tot_fin$CAD_status <- 0
sampleAnn_tot_fin$CAD_status[sampleAnn_tot_fin$Individual_ID %in% cases_id] <- 1

phenoDat_fin <- phenoDat_endo[match(final_id, rownames(phenoDat_endo)), ]
phenoInfo <- phenoInfo[match(colnames(phenoDat_fin), phenoInfo$pheno_id),]
# df <- cbind(data.frame(Dx = sampleAnn_tot_fin$CAD_status), phenoDat_fin)
# df$Dx <- factor(df$Dx)
# rm_col <- names(which(colSums(df[,grepl('41270_', colnames(df))], na.rm = T)<=50))
# df <- df[, !colnames(df) %in% rm_col]
# rm_col <- names(which(colSums(df[,grepl('20003_', colnames(df))],  na.rm = T)<=50))
# df <- df[, !colnames(df) %in% rm_col]
# mod_lm <- glm(Dx~0+.,family = 'binomial', df)

test_df <- data.frame(pheno_id = colnames(phenoDat_fin), Field = phenoInfo$Field, Coding_meaning = phenoInfo$Coding_meaning)
test_df$pval <- NA
test_df$pval_BHcorr <- NA
test_df$statistic <- NA
test_df$test_type <- NA
for(i in 1:ncol(phenoDat_fin)){
  print(i)
  if(is.integer(phenoDat_fin[,i])){
    tmp <- chisq.test(table(phenoDat_fin[,i], sampleAnn_tot_fin$CAD_status))
    test_df$pval[i] <- tmp$p.value
    test_df$statistic[i] <-tmp$statistic
    test_df$test_type[i] <- 'chisq'
  }else{
    tmp <- wilcox_test(phenoDat_fin[,i]~ factor(sampleAnn_tot_fin$CAD_status))
    test_df$pval[i] <- pvalue(tmp)
    test_df$statistic[i] <- tmp@statistic@teststatistic
    test_df$test_type[i] <- 'wilcox'
    
  }
}
test_df$pval_BHcorr <- p.adjust(test_df$pval, method = 'BH')

# test covariates
test_cov <- data.frame(cov_id = c(paste0('PC', 1:40), 'Age', 'Gender', 'Batch', 'Array', 'initial_assessment_centre'), stringsAsFactors = F)
test_cov$pval <- NA
test_cov$pval_BHcorr <- NA
test_cov$statistic <- NA
test_cov$test_type <- NA
for(i in 1:nrow(test_cov)){
  
  if(is.integer(sampleAnn_tot_fin[,colnames(sampleAnn_tot_fin) == test_cov$cov_id[i]]) | is.character(sampleAnn_tot_fin[,colnames(sampleAnn_tot_fin) == test_cov$cov_id[i]])){
    tmp <- chisq.test(table(sampleAnn_tot_fin[,colnames(sampleAnn_tot_fin) == test_cov$cov_id[i]], sampleAnn_tot_fin$CAD_status))
    test_cov$pval[i] <- tmp$p.value
    test_cov$statistic[i] <-tmp$statistic
    test_cov$test_type[i] <- 'chisq'
    
  }else{
    tmp <- wilcox_test(sampleAnn_tot_fin[,colnames(sampleAnn_tot_fin) == test_cov$cov_id[i]]~ factor(sampleAnn_tot_fin$CAD_status))
    test_cov$pval[i] <- pvalue(tmp)
    test_cov$statistic[i] <- tmp@statistic@teststatistic
    test_cov$test_type[i] <- 'wilcox'
    
  }
}
test_cov$pval_BHcorr <- p.adjust(test_cov$pval, method = 'BH')


# save results
CAD_subset <- list(sampleAnn = sampleAnn_tot_fin[, c('Individual_ID', 'CAD_status')], test_cov = test_cov, test_pheno = test_df)
save(CAD_subset, file = sprintf('%sCAD_HARD_clustering/subset_Association_COV-PHENO.RData', fold1))

tmp <- sampleAnn_tot_fin[, c('Individual_ID', 'CAD_status', paste0('PC', 1:10), 'Age', 'Gender', 'Array', 'Batch', 'initial_assessment_centre')]
colnames(tmp)[2] <- 'Dx'
write.table(tmp, file = sprintf('%sCAD_HARD_clustering/covariateMatrix_CADHARD_All.txt', fold1), col.names = T, row.names = F, sep = '\t', quote = F)

tmp <- sampleAnn_tot_fin[, c('Individual_ID', 'CAD_status', paste0('PC', 1:10), 'Age', 'Gender')]
colnames(tmp)[2] <- 'Dx'
write.table(tmp, file = sprintf('%sCAD_HARD_clustering/covariateMatrix_CADHARD_All_phenoAssoc.txt', fold1), col.names = T, row.names = F, sep = '\t', quote = F)

tmp <- cbind(data.frame(Individual_ID = rownames(phenoDat_fin), stringsAsFactors = F), phenoDat_fin)
write.table(tmp, file = sprintf('%sCAD_HARD_clustering/phenotypeMatrix_CADHARD_All.txt', fold1), col.names = T, row.names = F, sep = '\t', quote = F)

tmp <- phenoInfo[, 1:14]
write.table(tmp, file = sprintf('%sCAD_HARD_clustering/phenotypeDescription.txt', fold1), col.names = T, row.names = F, sep = '\t', quote = F)

# add medication info as covariates for endophenotype testing
pheno_id_tmp <- phenoInfo$pheno_id[phenoInfo$pheno_type %in% 'Medication' & (!phenoInfo$FieldID %in% c('6153', '6177')) & phenoInfo$pheno_id != '2492' & 
                                     phenoInfo$pheno_id != '6154_4' & phenoInfo$pheno_id != '6154_5' & phenoInfo$pheno_id != '6154_6' & 
                                     phenoInfo$pheno_id != '6155_7' & phenoInfo$pheno_id != '6179_1' &
                                     phenoInfo$Coding_meaning != 'None of the above']
phenoInfo_tmp <- phenoInfo[phenoInfo$pheno_id %in% pheno_id_tmp,]
tmp <- sampleAnn_tot_fin[, c('Individual_ID', 'CAD_status', paste0('PC', 1:10), 'Age', 'Gender')]
colnames(tmp)[2] <- 'Dx'
tmp <- cbind(tmp, phenoDat_fin[, pheno_id_tmp])
colnames(tmp)[colnames(tmp) %in% pheno_id_tmp] <- paste0('p', pheno_id_tmp)
pheno_id_tmp <- phenoInfo$pheno_id[phenoInfo$FieldID %in% c('6153', '6177') & phenoInfo$Coding_meaning != 'None of the above' & (!phenoInfo$pheno_id %in% c('6153_5', '6153_4'))]
phenoInfo_tmp <- rbind(phenoInfo_tmp, phenoInfo[phenoInfo$pheno_id %in% pheno_id_tmp,])

#_1
id_bothna <- rowSums(is.na(phenoDat_fin[, c('6153_1', '6177_1')])) == 2
tmp <- cbind(tmp, v1 = rep(NA, nrow(tmp)))
tmp$v1[!id_bothna] <-  rowSums(phenoDat_fin[, c('6153_1', '6177_1')] >=1, na.rm=T)[!id_bothna]
colnames(tmp)[ncol(tmp)] <- 'p6153_6177_1'

#_2
id_bothna <- rowSums(is.na(phenoDat_fin[, c('6153_2', '6177_2')])) == 2
tmp <- cbind(tmp, v1 = rep(NA, nrow(tmp)))
tmp$v1[!id_bothna] <-  rowSums(phenoDat_fin[, c('6153_2', '6177_2')] >=1, na.rm=T)[!id_bothna]
colnames(tmp)[ncol(tmp)] <- 'p6153_6177_2'

#_3
id_bothna <- rowSums(is.na(phenoDat_fin[, c('6153_3', '6177_3')])) == 2
tmp <- cbind(tmp, v1 = rep(NA, nrow(tmp)))
tmp$v1[!id_bothna] <-  rowSums(phenoDat_fin[, c('6153_3', '6177_3')] >=1, na.rm=T)[!id_bothna]
colnames(tmp)[ncol(tmp)] <- 'p6153_6177_3'

write.table(tmp, file = sprintf('%sCAD_HARD_clustering/covariateMatrix_CADHARD_All_phenoAssoc_withMedication.txt', fold1), col.names = T, row.names = F, sep = '\t', quote = F)
write.table(phenoInfo_tmp[, 1:14], file = sprintf('%sCAD_HARD_clustering/phenotypeDescription_covariateMatrix_withMedication.txt',fold1), col.names = T, row.names = F, sep = '\t', quote = F)

# save only certain pheno to be tested with medications
red_phenoDat_fin <- phenoDat_fin[, colnames(phenoDat_fin) %in% phenoInfo$pheno_id[phenoInfo$pheno_type %in% c('Alcohol', 'Arterial_stiffness', 'Blood_biochemistry', 'Blood_count', 
                                                                                                              'Blood_pressure', 'Body_size_measures', 'Diet', 'Hand_grip_strength', 
                                                                                                              'Impedance_measures', 'Physical_activity', 'Sleep', 'Smoking', 'Blood_count_ratio')]]
res_phenoInfo <- phenoInfo[match(colnames(red_phenoDat_fin), phenoInfo$pheno_id),]
tmp <- cbind(data.frame(Individual_ID = rownames(red_phenoDat_fin), stringsAsFactors = F), red_phenoDat_fin)
write.table(tmp, file = sprintf('%sCAD_HARD_clustering/phenotypeMatrix_CADHARD_All_phenoAssoc_withMedication.txt', fold1), col.names = T, row.names = F, sep = '\t', quote = F)

tmp <- res_phenoInfo[, 1:14]
write.table(tmp, file =  sprintf('%sCAD_HARD_clustering/phenotypeDescription_withMedication.txt', fold1), col.names = T, row.names = F, sep = '\t', quote = F)

red_phenoDat_fin <- phenoDat_fin[, !colnames(phenoDat_fin) %in% phenoInfo$pheno_id[phenoInfo$pheno_type %in% c('Alcohol', 'Arterial_stiffness', 'Blood_biochemistry', 'Blood_count', 
                                                                                                               'Blood_pressure', 'Body_size_measures', 'Diet', 'Hand_grip_strength', 
                                                                                                               'Impedance_measures', 'Physical_activity', 'Sleep', 'Smoking', 'Blood_count_ratio')]]
res_phenoInfo <- phenoInfo[match(colnames(red_phenoDat_fin), phenoInfo$pheno_id),]
tmp <- cbind(data.frame(Individual_ID = rownames(red_phenoDat_fin), stringsAsFactors = F), red_phenoDat_fin)
write.table(tmp, file = sprintf('%sCAD_HARD_clustering/phenotypeMatrix_CADHARD_All_phenoAssoc_withoutMedication.txt', fold1), col.names = T, row.names = F, sep = '\t', quote = F)

tmp <- res_phenoInfo[, 1:14]
write.table(tmp, file = sprintf('%sCAD_HARD_clustering/phenotypeDescription_withoutMedication.txt', fold1), col.names = T, row.names = F, sep = '\t', quote = F)


