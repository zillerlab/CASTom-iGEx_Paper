# create random prior for GTEx setting, both GWAS and EPI (wrt Ctrl_150_allPeaks_allRanger_Epi and heart_left_ventricle due to highest weights in Brain_cortex and Artery_Coronary)
# compute ranom priors:
# Ctrl_150_allPeaks_allRanger_Epi_random: same number of Ctrl_150_allPeaks_allRanger GRE randomply selected, then intersect with SNP position
# Ctrl_150_allPeaks_allRanger_Epi_random2x: 2x number of Ctrl_150_allPeaks_allRanger GRE randomply selected, then intersect with SNP position
# Ctrl_150_allPeaks_allRanger_Epi_random_noint: same number of Ctrl_150_allPeaks_allRanger GRE randomply selected, exclude GRE that intersect with GRE of the tissue, then intersect with SNP position
# Ctrl_150_allPeaks_allRanger_Epi_random2x_noint: 2x number of Ctrl_150_allPeaks_allRanger GRE randomply selected, exclude GRE that intersect with GRE of the tissue, then intersect with SNP position
# Ctrl_150_allPeaks_allRanger_var_random: randomly select significant (1) SNPs (same number as Ctrl_150_allPeaks_allRanger)
# Ctrl_150_allPeaks_allRanger_var_random2x: randomly select significant (1) SNPs (2x same number as Ctrl_150_allPeaks_allRanger)
# RANDOM_PGC_gwas: OR taken from PGC
# RANDOM_CAD_gwas: OR taken from CAD
# RANDOM_PGC_gwas_bin: binary version 10^-5
# RANDOM_CAD_gwas_bin: binary version 10^-3

options(max.print=1000)
options(stringsAsFactors = F)
library(Matrix)
cmdArgs=commandArgs(TRUE)

############
all_Chroms = 1:22
GRElib_file <- '/psycl/g/mpsziller/lucia/castom-igex/refData/prior_features/hg19.1.H3K27ac_GRElibrary_v2_rpkm_quantile_95th_binary.txt'
peak_files <- c('/psycl/g/mpsziller/lucia/castom-igex/refData/prior_features/FinalIDR_FPC_neuronal_ATAC_R2_macs2.bed', '/psycl/g/mpsziller/lucia/castom-igex/refData/prior_features/FinalIDR_FPC_neuronal_ATAC_R4_macs2.bed',
                '/psycl/g/mpsziller/lucia/castom-igex/refData/prior_features/hg19_Ctrl_150_allPeaks_cellRanger.bed')
priorMat_file <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/priorMatrix_'
var_epi_file <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/hg19_SNPs-Epi_'
output <-  '/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/'
names_peak <- c('FPC_neuronal_ATAC_R2', 'FPC_neuronal_ATAC_R4', 'Ctrl_150_allPeaks_cellRanger')
perc_thr <- 0.4
n_rep <- 50
id_chr <- cmdArgs[1]
###########

GRElib <- read.table(GRElib_file, header = T, stringsAsFactors = F)
peak <- lapply(peak_files, function(x) read.table(x, stringsAsFactors = F, sep = '\t'))

for(i in 1:length(peak)){
  peak[[i]] <- peak[[i]][, 1:3]  
  colnames(peak[[i]]) <- c('chrom', 'chromstart', 'chromend')
  if(length(strsplit(peak[[i]]$chrom[1], split = 'chr')[[1]]) == 1){
    peak[[i]]$chrom <- paste0('chr', peak[[i]]$chrom)
  }
}

all_Chroms = 1:22

len_peakAdd <- sapply(peak, nrow)
len_lib <- apply(GRElib[, 5:ncol(GRElib)], 2, function(x) table(x))[2,]
id <- which(len_peakAdd/mean(len_lib)<perc_thr)
len <- unname(apply(GRElib[, 2:3], 1, function(x) x[2] - x[1]))

if(length(id)>0){
  len_tmp <- lapply(id, function(y) unname(apply(peak[[y]][, 2:3], 1, function(x) x[2] - x[1])))
  for(i in 1:length(id)){
    colnames(peak[[id[i]]]) <-  c('chrom', 'chromstart_old', 'chromend_old')
    peak[[id[i]]]$chromstart <- unname(apply(peak[[id[i]]][,2:3],1, function(x) sum(x)/2)) - len_tmp[[id[i]]]/2 - median(len)/2
    peak[[id[i]]]$chromend <- unname(apply( peak[[id[i]]][,2:3],1, function(x) sum(x)/2)) + len_tmp[[id[i]]]/2 + median(len)/2
  }
}


BC_epi <- read.table('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/Brain_Cortex/priorName_nogwas_withIndex.txt', header = F, stringsAsFactors = F)
AC_epi <- read.table('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/OUTPUT_SCRIPTS_v2/Artery_Coronary/priorName_nogwas_withIndex.txt',  header = F, stringsAsFactors = F)
                     

# create random prior
id_chr <- as.numeric(id_chr)
curChrom <- paste0("chr", id_chr)
print(curChrom)

epiAn <- read.table(gzfile(sprintf("%s%s_matched.txt.gz", var_epi_file, curChrom)),sep="\t",header=T)
priorMat <- read.table(gzfile(paste0(priorMat_file,curChrom,'.txt.gz')),sep="\t",header = T)
id_BC_epi <- rowSums(priorMat[, colnames(priorMat) %in% BC_epi$V2])>1
id_AC_epi <- rowSums(priorMat[, colnames(priorMat) %in% AC_epi$V2])>1


GRElib_chr <- GRElib[GRElib$chrom == curChrom, ] 
# GRElib_all_chr <- GRElib_all[GRElib_all$chrom == curChrom, ]
peak_chr <- lapply(peak, function(x) x[x$chrom == curChrom, ])
peak_chr <- lapply(peak_chr, function(x) x[, colnames(x) %in% c('chrom', 'chromstart', 'chromend')])

GREs_tot <- rbind(GRElib_chr[,1:3], do.call(rbind, peak_chr))
GREs_tot$type <- c(rep('GRElib_all', nrow(GRElib_chr)), unlist(mapply(function(x,y) rep(x, y), x = names_peak, y = sapply(peak_chr, nrow))))
tmp <- cbind(GRElib_chr[, 1:3], GRElib_chr[, colnames(GRElib_chr) %in% BC_epi$V2])
GREs_tot_noBC <- tmp[rowSums(tmp[, 4:ncol(tmp)]) == 0 ,1:3]
tmp <- cbind(GRElib_chr[, 1:3], GRElib_chr[, colnames(GRElib_chr) %in% AC_epi$V2])
GREs_tot_noAC <- tmp[rowSums(tmp[, 4:ncol(tmp)]) ==0, 1:3]

# create new annotation
# epiAn_random <- cbind(epiAn[,1:5], matrix(0, nrow = nrow(epiAn), ncol = 10*n_rep))
epiAn_random <- lapply(1:n_rep, function(x) matrix(0, nrow = nrow(epiAn), ncol = 10))

for(j in 1:n_rep){
  
  print(j)
  
  ### brain cortex ###
  set.seed(1234*id_chr*j + id_chr)
  id_random <- sample(x = 1:nrow(GREs_tot), size = nrow(peak_chr[[3]]))
  GREs_random_b <- GREs_tot[id_random,]
  
  set.seed(1235*id_chr*j + id_chr)
  id_random_2x <- sample(x = 1:nrow(GREs_tot), size = 2*nrow(peak_chr[[3]]))
  GREs_random_b_2x <- GREs_tot[id_random_2x,]
  
  if(nrow(peak_chr[[3]])<nrow(GREs_tot_noBC)){
    set.seed(1236*id_chr*j + id_chr)
    id_random_noint <- sample(x = 1:nrow(GREs_tot_noBC), size = nrow(peak_chr[[3]]))
    GREs_random_b_noint <- GREs_tot_noBC[id_random_noint, ]
  }else{
    GREs_random_b_noint <- GREs_tot_noBC
  }
  
  # order
  GREs_random_b <- GREs_random_b[order(GREs_random_b$chromstart), ]
  GREs_random_b_2x <- GREs_random_b_2x[order(GREs_random_b_2x$chromstart), ]
  GREs_random_b_noint <- GREs_random_b_noint[order(GREs_random_b_noint$chromstart), ]
  
  ## random
  # find intersectiong SNPs
  id <- sapply(1:nrow(epiAn), function(x){
    id_r <- which(epiAn[x,2] <= GREs_random_b$chromend & epiAn[x,2]>= GREs_random_b$chromstart)
    # if(length(id_r)==0){id_r <- 0}
    return(id_r)})
  index_id <- which(sapply(id, function(x) length(x)>0))
  epiAn_random[[j]][index_id, 1] <- 1
  
  
  ## random x2
  # find intersectiong SNPs
  id <- sapply(1:nrow(epiAn), function(x){
    id_r <- which(epiAn[x,2] <= GREs_random_b_2x$chromend & epiAn[x,2]>= GREs_random_b_2x$chromstart)
    # if(length(id_r)==0){id_r <- 0}
    return(id_r)})
  index_id <- which(sapply(id, function(x) length(x)>0))
  epiAn_random[[j]][index_id, 2] <- 1
  
  ## random noint
  # find intersectiong SNPs
  id <- sapply(1:nrow(epiAn), function(x){
    id_r <- which(epiAn[x,2] <= GREs_random_b_noint$chromend & epiAn[x,2]>= GREs_random_b_noint$chromstart)
    # if(length(id_r)==0){id_r <- 0}
    return(id_r)})
  index_id <- which(sapply(id, function(x) length(x)>0))
  epiAn_random[[j]][index_id, 3] <- 1
  
  
  ### random SNPs
  set.seed(1237*id_chr*j+id_chr)
  # random 
  id_random_var <- sample(x = 1:nrow(epiAn_random[[j]]), size = length(which(epiAn$Ctrl_150_allPeaks_cellRanger == 1)))
  epiAn_random[[j]][id_random_var, 4] <- 1
  # random x2 
  set.seed(1238*id_chr*j+id_chr)
  id_random_2x_var <- sample(x = 1:nrow(epiAn_random[[j]]), size = 2*length(which(epiAn$Ctrl_150_allPeaks_cellRanger == 1)))
  epiAn_random[[j]][id_random_2x_var, 5] <- 1
  
  
  ### artery coronary ###
  set.seed(1239*id_chr*j + id_chr)
  id_random <- sample(x = 1:nrow(GREs_tot), size = length(which(GRElib_chr$heart_left_ventricle == 1)))
  GREs_random_a <- GREs_tot[id_random,]
  
  set.seed(1240*id_chr*j + id_chr)
  id_random_2x <- sample(x = 1:nrow(GREs_tot), size = 2*length(which(GRElib_chr$heart_left_ventricle == 1)))
  GREs_random_a_2x <- GREs_tot[id_random_2x,]
  
  if(length(which(GRElib_chr$heart_left_ventricle == 1))<nrow(GREs_tot_noAC)){
    set.seed(1241*id_chr*j + id_chr)
    id_random_noint <- sample(x = 1:nrow(GREs_tot_noAC), size = length(which(GRElib_chr$heart_left_ventricle == 1)))
    GREs_random_a_noint <- GREs_tot_noAC[id_random_noint, ]
  }else{
    GREs_random_a_noint <- GREs_tot_noAC
  }
  
  
  # order
  GREs_random_a <- GREs_random_a[order(GREs_random_a$chromstart), ]
  GREs_random_a_2x <- GREs_random_a_2x[order(GREs_random_a_2x$chromstart), ]
  GREs_random_a_noint <- GREs_random_a_noint[order(GREs_random_a_noint$chromstart), ]
  
  ## random
  # find intersectiong SNPs
  id <- sapply(1:nrow(epiAn), function(x){
    id_r <- which(epiAn[x,2] <= GREs_random_a$chromend & epiAn[x,2]>= GREs_random_a$chromstart)
    # if(length(id_r)==0){id_r <- 0}
    return(id_r)})
  index_id <- which(sapply(id, function(x) length(x)>0))
  epiAn_random[[j]][index_id, 6] <- 1
  
  
  ## random x2
  # find intersectiong SNPs
  id <- sapply(1:nrow(epiAn), function(x){
    id_r <- which(epiAn[x,2] <= GREs_random_a_2x$chromend & epiAn[x,2]>= GREs_random_a_2x$chromstart)
    # if(length(id_r)==0){id_r <- 0}
    return(id_r)})
  index_id <- which(sapply(id, function(x) length(x)>0))
  epiAn_random[[j]][index_id, 7] <- 1
  
  ## random noint
  # find intersectiong SNPs
  id <- sapply(1:nrow(epiAn), function(x){
    id_r <- which(epiAn[x,2] <= GREs_random_a_noint$chromend & epiAn[x,2]>= GREs_random_a_noint$chromstart)
    # if(length(id_r)==0){id_r <- 0}
    return(id_r)})
  index_id <- which(sapply(id, function(x) length(x)>0))
  epiAn_random[[j]][index_id, 8] <- 1
  
  ### random SNPs
  set.seed(1242*id_chr*j+id_chr)
  # random 
  id_random_var <- sample(x = 1:nrow(epiAn_random[[j]]), size = length(which(epiAn$heart_left_ventricle == 1)))
  epiAn_random[[j]][id_random_var, 9] <- 1
  # random x2 
  set.seed(1243*id_chr*j+id_chr)
  id_random_2x_var <- sample(x = 1:nrow(epiAn_random[[j]]), size = 2*length(which(epiAn$heart_left_ventricle == 1)))
  epiAn_random[[j]][id_random_2x_var, 10] <- 1
  
  original_names <- c('Ctrl_150_allPeaks_allRanger_Epi_random', 'Ctrl_150_allPeaks_allRanger_Epi_random2x', 'Ctrl_150_allPeaks_allRanger_Epi_random_noint',
                      'Ctrl_150_allPeaks_allRanger_Var_random', 'Ctrl_150_allPeaks_allRanger_Var_random2x', 
                      'heart_left_ventricle_Epi_random', 'heart_left_ventricle_Epi_random2x',  'heart_left_ventricle_Epi_random_noint', 
                      'heart_left_ventricle_Var_random', 'heart_left_ventricle_Var_random2x')
  
  colnames(epiAn_random[[j]]) <- sapply(1:ncol(epiAn_random[[j]]), function(x) paste0(original_names[x], '_', 'r', j))  
}

### save
final_epi <- cbind(epiAn[1:6], do.call(cbind, epiAn_random))

write.table(file = sprintf("%s%srandomSC_%s_matched.txt", output, 'hg19_SNPs-Epi_', curChrom), x = epiAn_random, sep="\t", col.names = T, row.names = F, quote = F)
system(paste("gzip",sprintf("%s%srandomSC_%s_matched.txt", output, 'hg19_SNPs-Epi_', curChrom)))

################################################################################################################################################





