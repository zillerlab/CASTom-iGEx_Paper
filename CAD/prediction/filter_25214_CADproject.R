# filter CAD (id 25214) name samples based on SCZ (id 34217) project samples 

sample_25214=read.table("/psycl/g/mpsukb/UKBB_hrc_imputation/ukb25214_imp_chr1_v3_s487317.sample",header = TRUE)[-1, ]
sample_34217 = read.table("/psycl/g/mpsukb/UKBB_hrc_imputation/ukb34217_imp_chr1_v3_s487317.sample",header = TRUE)[-1, ]

filtered_samples_34217 <- read.table("/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/split_samples_unrelated_ukb34217", h=F)
id_keep <- which(sample_34217$ID_1 %in% filtered_samples_34217$V1)

filtered_samples_25214 <- sample_25214[id_keep, ]
df <- data.frame(ukb25214 = filtered_samples_25214$ID_1, ukb34217 = sample_34217$ID_1[id_keep])
write.table(x = df, file = '/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/samples_unrelated_ukb25214_ukb34217', col.names = T, row.names = F, quote = F, sep = '\t')