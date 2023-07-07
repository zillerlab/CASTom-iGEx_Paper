# create sample tables
# All samples (Caucasian)
# All controls
# 50 controls
# 100 controls
# 150 controls

# load from covariate file, already filtering for matching expression and caucasian
covMat <- read.table('/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Covariates/covariateMatrix.txt', header = T, stringsAsFactors = F, sep = '\t')

sampleAll <- covMat
write.table('/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/train_All/covariateMatrix_All.txt', x = sampleAll, col.names = T, row.names = F, sep = '\t', quote = F)

sampleAll_controls <- covMat[covMat$Dx == 0,]
write.table('/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/train_ControlAll/covariateMatrix_ControlAll.txt', x = sampleAll_controls, col.names = T, row.names = F, sep = '\t', quote = F)

set.seed(1234)
sample_50controls <- sampleAll_controls[sort(sample(1:nrow(sampleAll_controls), 50)),]
write.table('/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/train_Control50/covariateMatrix_Control50.txt', x = sample_50controls, col.names = T, row.names = F, sep = '\t', quote = F)

set.seed(42)
sample_100controls <- sampleAll_controls[sort(sample(1:nrow(sampleAll_controls), 100)),]
write.table('/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/train_Control100/covariateMatrix_Control100.txt', x = sample_100controls, col.names = T, row.names = F, sep = '\t', quote = F)

set.seed(19)
sample_150controls <- sampleAll_controls[sort(sample(1:nrow(sampleAll_controls), 150)),]
write.table('/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v2/train_Control150/covariateMatrix_Control150.txt', x = sample_150controls, col.names = T, row.names = F, sep = '\t', quote = F)

