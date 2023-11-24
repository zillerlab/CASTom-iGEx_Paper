# annotate correctly ukbb sample qc file
setwd('/psycl/g/mpsukb/UKBB_hrc_imputation')
fam_file <- 'ukb34217_cal_chr22_v2_s488282.fam'
sampleQC <- 'ukb_sqc_v2.txt.gz'
imp_file <- 'ukb34217_imp_chr1_v3_s487317.sample'
filt_white_file <- 'oxford/ukb34217_imp_chr1_v3_s487317.filtered.sample'
rm_relatives <- 'relatives_toremove_filtered_white_british_34217.txt'
age_var <- '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/age_ukb23895_filtered_britishWhiteUnrelated_pheno.tab'
# kinship_mat <- '/psycl/g/mpsziller/lucia/UKBB/phenotype_data/ukb34217_rel_s488282.dat'


sampleQC <- read.table(gzfile(sampleQC), h=F, stringsAsFactors = F, sep = ' ')
sampleImp <- read.table(imp_file, header = T, stringsAsFactors = F)[-1,]   	  	   

# create correct column name
colnames(sampleQC) <- c('Affymetrix_v1', 'Affymetrix_v2', 'genotyping_array', 'Batch', 'Plate_Name', 'Well', 'Cluster_CR', 'dQC', 'Internal_Pico_ng_uL', 'Submitted_Gender', 
                        'Inferred_Gender', 'X_intensity', 'Y_intensity', 'Submitted_Plate_Name', 'Submitted_Well', 'sample_qc_missing_rate', 'heterozygosity', 'heterozygosity_pc_corrected',
                        'het_missing_outliers', 'putative_sex_chromosome_aneuploidy', 'in_kinship_table', 'excluded_from_kinship_inference', 'excess_relatives', 'in_white_British_ancestry_subset', 'used_in_pca_calculation', 
                        paste0('PC', 1:40), 'in_Phasing_Input_chr1_22', 'in_Phasing_Input_chrX', 'in_Phasing_Input_chrXY')

sampleID <- read.table(fam_file, header = F, stringsAsFactors = F)   	  	   
sampleQC$genoSample_ID <- sampleID$V1
rm_relatives <- read.table(rm_relatives, h=F, stringsAsFactors = F)
filt_white <- read.table(filt_white_file, header = T, stringsAsFactors = F)[-1,]
sampleQC$filt_white_british <- 1
sampleQC$filt_white_british[! sampleQC$genoSample_ID %in% filt_white$ID_1] <- 0
sampleQC$filt_white_british_norel <- sampleQC$filt_white_british
sampleQC$filt_white_british_norel[sampleQC$genoSample_ID %in% filt_white$ID_1 & sampleQC$genoSample_ID %in% rm_relatives$V1] <- 0

# save
write.table(x = sampleQC, file ='ukb_sqc_v2_annotated_34217.txt', col.names = T, row.names = F, sep = '\t', quote = F)

# note: sample 2951611 missing from sampleQC file
# create final covariate file for the filtered samples
sampleQC_filt <- sampleQC[sampleQC$filt_white_british_norel == 1,]
# all(sampleQC_filt$in_white_British_ancestry_subset == 1) # TRUE, they are all white british
 
# remove based on not matching sex
sampleQC_filt <- sampleQC_filt[sampleQC_filt$Submitted_Gender == sampleQC_filt$Inferred_Gender,]
# remove samples based on outliers
sampleQC_filt <- sampleQC_filt[sampleQC_filt$het_missing_outliers == 0,]

# considering the relativness, there is no need to filter based on excess_relatives, there could still be some ones but the corresponding relatives are not in the matrix
# consider only the covariates to be used
sampleQC_filt <- cbind(data.frame(Individual_ID = paste0('X', sampleQC_filt$genoSample_ID),genoSample_ID = sampleQC_filt$genoSample_ID,  stringsAsFactors = F), 
                       sampleQC_filt[, !colnames(sampleQC_filt) %in% 'genoSample_ID'])

sampleQC_filt <- sampleQC_filt[, c('Individual_ID', 'genoSample_ID', 'genotyping_array', 'Inferred_Gender', paste0('PC', 1:20))]
# Array == 0 (UKBB), genotype_array == 0 (UKBL)
# Gender == 0 (M), gender == 1 (F)
sampleQC_filt$Gender <- 0
sampleQC_filt$Gender[sampleQC_filt$Inferred_Gender == 'F'] <- 1
sampleQC_filt$Array <- 0
sampleQC_filt$Array[sampleQC_filt$genotype_array == 'UKBL'] <- 1
sampleQC_filt <- sampleQC_filt[, !colnames(sampleQC_filt) %in% c('genotyping_array', 'Inferred_Gender')]

# add age 
age_var <- read.table(age_var, h=T, stringsAsFactors = F)
age_var <- age_var[age_var[,1] %in% sampleQC_filt$genoSample_ID,]
sampleQC_filt <- merge(y = age_var, x = sampleQC_filt, by.y = 'userId', by.x = 'genoSample_ID', sort = F)
colnames(sampleQC_filt)[ncol(sampleQC_filt)] <- 'Age'

# save 
write.table(x = sampleQC_filt, file = '/psycl/g/mpsziller/lucia/UKBB/eQTL_PROJECT/INPUT_DATA/Covariates/covariatesMatrix.txt', col.names = T, row.names = F, quote = F, sep = '\t')



