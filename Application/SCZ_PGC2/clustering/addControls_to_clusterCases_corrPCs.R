# create cluster annotation with controls and group of cases:
name_cohorts <- read.table('INPUT_DATA/SCZ_cohort_names_CLUST')$V1
sampleAnnFile <- paste0('INPUT_DATA/Covariates/',name_cohorts,'.covariateMatrix_old.txt')
clusterFile <- 'OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_minimal.RData'

cl_cases <- get(load(clusterFile))

sampleAnn <- list()
print(i)
for(i in 1:length(name_cohorts)){
  tmp <- read.table(sampleAnnFile[i], h=T, stringsAsFactors = F, sep = '\t')
  tmp$cohort <- name_cohorts[i]
  tmp$cohort_id <- i
  # remove cases not in clustering
  tmp <- tmp[tmp$Individual_ID %in% cl_cases$samples_id | tmp$Dx == 0, ]
  sampleAnn[[i]] <- tmp
}
sampleAnn <- do.call(rbind, sampleAnn)
cl_tot <- list(sampleInfo = sampleAnn, sampleOutliers = cl_cases$sampleOutliers, 
               samples_id = sampleAnn$Individual_ID)
cl_tot$cl_best <- data.frame(id = sampleAnn$Individual_ID, gr = NA, stringsAsFactors = F)
cl_tot$cl_best$gr[sampleAnn$Dx == 0] <- 0
cl_tot$cl_best$gr[match(cl_cases$cl_best$id, cl_tot$cl_best$id)] <- cl_cases$cl_best$gr

# save
save(cl_tot, 
     file = 'OUTPUT_CMC/predict_PGC/200kb/Meta_Analysis_SCZ/devgeno0.01_testdevgeno0/update_corrPCs/matchUKBB_tscore_corrPCs_zscaled_clusterCases_addControls_PGmethod_HKmetric_minimal.RData')

