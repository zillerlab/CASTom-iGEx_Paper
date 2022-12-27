# create random phenotype with CAD dimension from UKBB
fold <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD/Covariates/UKBB/'
n_rep <- 50

sampleAnn <- read.table(sprintf('%scovariateMatrix_latestW.txt', fold), header = T, stringsAsFactors = F, sep = '\t')
phenoCAD <- read.table(sprintf('%sphenoMatrix_updateCADHARD.txt', fold), header = T, stringsAsFactors = F, sep = '\t')
phenoCAD <- phenoCAD[match(sampleAnn$Individual_ID,phenoCAD$Individual_ID),]
sampleAnn_tot <- read.table(sprintf('%scovariatesMatrix_batchInfo.txt', fold), h=T, stringsAsFactors=F, sep = '\t')
sampleAnn_tot <- sampleAnn_tot[match(sampleAnn$Individual_ID,sampleAnn_tot$Individual_ID),]

N_cases <- sum(phenoCAD$CAD_HARD == 1)
N_male_cases <- sum(phenoCAD$CAD_HARD == 1 & sampleAnn$Gender == 0)
N_female_cases <- sum(phenoCAD$CAD_HARD == 1 & sampleAnn$Gender == 1)

age_set <- sort(unique(sampleAnn_tot$Age[phenoCAD$CAD_HARD == 1]))
n_age_sex <- data.frame(age = rep(age_set,2), 
                           sex = c(rep(0, length(age_set)), rep(1, length(age_set))), 
                           n=NA, stringsAsFactors = F)
for(i in 1:length(age_set)){
  
  # male
  n_age_sex$n[n_age_sex$age == age_set[i] & n_age_sex$sex == 0] <- sum(phenoCAD$CAD_HARD == 1 & sampleAnn$Gender == 0 & sampleAnn_tot$Age == age_set[i])
  # female
  n_age_sex$n[n_age_sex$age == age_set[i] & n_age_sex$sex == 1] <- sum(phenoCAD$CAD_HARD == 1 & sampleAnn$Gender == 1 & sampleAnn_tot$Age == age_set[i])
}

# create random phenotype matched by age and gender
pheno_random_matched <- data.frame(Individual_ID = phenoCAD$Individual_ID, stringsAsFactors = F)
tmp <- vector(mode = 'list', length = n_rep)

for(rep_id in 1:n_rep){
  
  tmp[[rep_id]] <- rep(0, nrow(pheno_random_matched))
  id_samples_random <- c()

  for(row_id in 1:nrow(n_age_sex)){
    
    seed_id <- n_rep*(row_id -1) + rep_id
    # print(seed_id)
    
    id_samples <- sampleAnn_tot$Individual_ID[sampleAnn_tot$Age == n_age_sex$age[row_id] & sampleAnn$Gender == n_age_sex$sex[row_id]]
    
    set.seed(seed_id)
    id_samples_random <- c(id_samples_random, sample(id_samples, size =  n_age_sex$n[row_id], replace = F))
    
  }
  tmp[[rep_id]][pheno_random_matched$Individual_ID %in% id_samples_random] <- 1
}

pheno_random_matched <- cbind(pheno_random_matched, do.call(cbind, tmp))
colnames(pheno_random_matched)[-1] <- paste0('randomCAD_matchedAgeSex_', 1:n_rep)


# create random phenotype (only matched by number of cases)
pheno_random <- data.frame(Individual_ID = phenoCAD$Individual_ID, stringsAsFactors = F)
tmp <- vector(mode = 'list', length = n_rep)

for(rep_id in 1:n_rep){
  
  tmp[[rep_id]] <- rep(0, nrow(pheno_random))
  id_samples <- sampleAnn_tot$Individual_ID
  
  set.seed(rep_id)
  id_samples_random <- sample(id_samples, size = N_cases, replace = F)
    
  tmp[[rep_id]][pheno_random$Individual_ID %in% id_samples_random] <- 1
}

pheno_random <- cbind(pheno_random, do.call(cbind, tmp))
colnames(pheno_random)[-1] <- paste0('randomCAD_', 1:n_rep)

## create pheno description files ##
phenoDesc_CAD <- read.table(sprintf('%sphenotypeDescription_CAD.txt', fold), header = T, stringsAsFactors = F, sep = '\t')

phenoDesc_random_matched <- data.frame(pheno_id = colnames(pheno_random_matched)[-1], 
                               FieldID = colnames(pheno_random_matched)[-1], 
                               Field = colnames(pheno_random_matched)[-1],
                               Sexed = 'Unisex', original_type = 'CAT_SINGLE', transformed_type = 'CAT_SINGLE_UNORDERED', 
                               nsamples = nrow(pheno_random_matched), nsamples_T = N_cases, nsamples_F = nrow(pheno_random_matched) - N_cases)


phenoDesc_random <- data.frame(pheno_id = colnames(pheno_random)[-1], 
                                       FieldID = colnames(pheno_random)[-1], 
                                       Field = colnames(pheno_random)[-1],
                                       Sexed = 'Unisex', original_type = 'CAT_SINGLE', transformed_type = 'CAT_SINGLE_UNORDERED', 
                                       nsamples = nrow(pheno_random), nsamples_T = N_cases, nsamples_F = nrow(pheno_random) - N_cases)


## save ##
write.table(file = sprintf('%sphenotypeMatrix_randomCAD.txt', fold), x = pheno_random, quote = F, sep = '\t', 
            col.names = T, row.names = F)
write.table(file = sprintf('%sphenotypeMatrix_randomCAD_matchedAgeSex.txt', fold), x = pheno_random_matched, quote = F, sep = '\t', 
            col.names = T, row.names = F)
write.table(file = sprintf('%sphenotypeDescription_randomCAD.txt', fold),
            x = rbind(phenoDesc_random,phenoDesc_random_matched), quote = F, sep = '\t', 
            col.names = T, row.names = F)




