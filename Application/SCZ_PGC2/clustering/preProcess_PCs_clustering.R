# create files to cluster PCs
options(stringsAsFactors=F)
options(max.print=1000)

mdsFile = '//home/pgcdac/DWFV2CJb8Piv_0116_pgc_data/scz/wave2/v1/prune.bfile.cobg.PGC_SCZ49.sh2.menv.mds_cov'
mds_res <- read.table(mdsFile, h=T, stringsAsFactors = F)
rownames(mds_res) <- paste(mds_res$FID, mds_res$IID, sep = '_') 
mds_res <- as.matrix(mds_res[, paste0('C', 1:20)])

# load and combine sampleAnn
name_cohorts <- read.table('/home/luciat/eQTL_PROJECT/INPUT_DATA/SCZ_cohort_names_CLUST', header = F, stringsAsFactors = F)$V1
sampleAnn_file=paste0('/home/luciat/eQTL_PROJECT/INPUT_DATA/Covariates/',name_cohorts,'.covariateMatrix_old.txt')

### load score data ###
sampleAnn <- vector(mode = 'list', length = length(name_cohorts))

for(c_id in 1:length(name_cohorts)){
  
  print(name_cohorts[c_id])
  
  sampleAnn[[c_id]] <- read.table(sampleAnn_file[[c_id]], h = T, stringsAsFactors = F)
  sampleAnn[[c_id]]$cohort <- rep(name_cohorts[c_id], nrow(sampleAnn[[c_id]]))
  sampleAnn[[c_id]]$cohort_id <- rep(c_id, nrow(sampleAnn[[c_id]]))

}
sampleAnn <- do.call(rbind, sampleAnn)

# save
write.table(file = '/home/luciat/eQTL_PROJECT/INPUT_DATA/Covariates/PCs_cluster/samples_PCs_clustering.txt', x = sampleAnn, 
            quote = F, sep = '\t', col.names = T, row.names = F)
save(mds_res, file = '/home/luciat/eQTL_PROJECT/INPUT_DATA/Covariates/PCs_cluster/C1-20_PGC_clustering.RData')

