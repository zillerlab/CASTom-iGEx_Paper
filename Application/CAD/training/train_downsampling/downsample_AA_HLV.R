library(dplyr)

downsample <- function(outFold, sampling_perc, seed = 1234) {
  
  sampleAnn <- read.table(sprintf("%scovariates_EuropeanSamples.txt", outFold), h=T, stringsAsFactors = F)
  
  n_samples <- nrow(sampleAnn)
  
  set.seed(seed)
  id <- sample(seq_len(n_samples), round(n_samples*sampling_perc/100)) %>% sort
  downSampleAnn <- sampleAnn[id, ]
  print(nrow(downSampleAnn))
  
  write.table(file = sprintf("%scovariates_EuropeanSamples_downsample%i.txt", outFold, sampling_perc), 
              x = downSampleAnn, quote = F, sep = "\t", col.names = T, row.names = F)
}

###
tissues <- c("Artery_Aorta", "Heart_Left_Ventricle")
outFold <- sprintf(
  "/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/Covariates/%s/", 
  tissues)
perc_values <- c(50, 70, 90)

for(i in perc_values){
  
  # Artery Aorta
  downsample(outFold = outFold[1], sampling_perc = i, seed = 2345 + i)
  
  # Heart Left Ventricle
  downsample(outFold = outFold[2], sampling_perc = i, seed = 2345 + i)
  
}


