# prepare input file,
# write genotype dosage in the correct order and info
# match with gwas file

options(max.print=1000)
options(stringsAsFactors = F)
library(Matrix)
library(argparse)

parser <- ArgumentParser(description="write genotype in the correct format, filter gwas PGC")

parser$add_argument("--pathGeno", type = "character", help = "path to dosage genotype data")
parser$add_argument("--nameGeno", type = "character", help = "Common name genotype, add correct chr")
parser$add_argument("--pathInfo", type = "character", help = "path to info genotype data")
parser$add_argument("--nameGWAS", type = "character", help = "path + name to gwas data")
parser$add_argument("--curChrom", type = "character", help = "chromosome considered")

args <- parser$parse_args()
pathGeno <- args$pathGeno
nameGeno <- args$nameGeno
pathInfo <- args$pathInfo
nameGWAS <- args$nameGWAS
curChrom <- args$curChrom

# ###########################
# pathGeno <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/'
# nameGeno <- 'filtered_chr_corRefAlt'
# pathInfo <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/Genotyping_data/'
# curChrom <- 'chr8'
# nameGWAS <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_CMC/INPUT_DATA/PGC/Original_SCZ_variants_chr.txt'
# ###########################


###########################
# function to check indel annotation
check_indels_fun <- function(x){
  x <- unlist(x)
  x <- x[5:8]
  x <- x[nchar(x)>1] # first ref or alt, second a1 or a2
  res <- unname(nchar(x[1]) == as.numeric(strsplit(x[2], split = 'I')[[1]][2]))
  return(res)
}
###########################

nameGeno <- strsplit(nameGeno, split = 'chr')
nameGeno <- paste0(nameGeno[[1]][1], curChrom, nameGeno[[1]][2])

nameGWAS <- strsplit(nameGWAS, split = 'chr')
nameGWAS <- paste0(nameGWAS[[1]][1], curChrom, nameGWAS[[1]][2])


# load gwas data
gwas_data <- read.table(nameGWAS, header = F, stringsAsFactors = F)
colnames(gwas_data) <- c('CHR', 'SNP', 'A1', 'A2', 'BP', 'info', 'OR', 'SE', 'P', 'ngt')

# load geno data 
geno_dat_snps <- read.table(sprintf('%sSNPs/%s_snps_matrixeQTL.geno', pathGeno, nameGeno), header = T, sep = '\t', stringsAsFactors = F)
geno_dat_indels <- read.table(sprintf('%sINDELS/%s_indels_matrixeQTL.geno', pathGeno, nameGeno), header = T, stringsAsFactors = F)
  
# load info file and adjust based on position
info_snps <- read.table(sprintf('%sSNPs/%s_snps.afreq', pathInfo, nameGeno), header = T, stringsAsFactors = F)
info_indels <- read.table(sprintf('%sINDELS/%s_indels.afreq', pathInfo, nameGeno), header = T, stringsAsFactors = F)

###### match gwas data and geno ######
# use position, name con be different ]
## snps
pos_snps <- intersect(info_snps$POS, gwas_data$BP)
print(paste('all snps position in geno:', all(info_snps$POS %in% pos_snps)))
gwas_data_snps <-  gwas_data[gwas_data$BP %in% pos_snps, ] # dimension can be different, some indels present
gwas_data_snps <- gwas_data_snps[!(gwas_data_snps$A1 == 'D'|gwas_data_snps$A2 == 'D'), ]
gwas_data_snps <- gwas_data_snps[order(gwas_data_snps$BP), ]
info_snps <- info_snps[order(info_snps$POS), ]
print(paste('same snps postion gwas and geno:', identical(info_snps$POS, gwas_data_snps$BP)))
# combine:
total_info_snps <- data.frame(CHR = info_snps$CHR, POS =info_snps$POS, ID_CMC = info_snps$ID , ID_PGC = gwas_data_snps$SNP, REF = info_snps$REF,
                              ALT = info_snps$ALT, A1 = gwas_data_snps$A1, A2 = gwas_data_snps$A2, ALT_freq =info_snps$ALT_frq, 
                              OR = gwas_data_snps$OR, SE = gwas_data_snps$SE, PVAL= gwas_data_snps$P)
# check ref/alt same as a1/a2
check_snps <- apply(total_info_snps, 1, function(x) all(x[5:6] %in% x[7:8]))
if(all(check_snps)){
  print('snps ref/alt same as a1/a2')
}else{
  print('snps ref/alt DIFFERENT from a1/a2, exclude')
  total_info_snps <- total_info_snps[check_snps,]  
}

## indels
pos_indels <- intersect(info_indels$POS, gwas_data$BP)
print(paste('all indels position in geno:', all(info_indels$POS %in% pos_indels)))
gwas_data_indels <-  gwas_data[gwas_data$BP %in% pos_indels, ] # dimension can be different, some snps present
gwas_data_indels <- gwas_data_indels[gwas_data_indels$A1 == 'D'|gwas_data_indels$A2 == 'D', ]
# remove deletion/duplication
gwas_data_indels <- gwas_data_indels[sapply(gwas_data_indels$SNP, function(x) strsplit(x, split = '_')[[1]][1]) != 'MERGED',]

gwas_data_indels <- gwas_data_indels[order(gwas_data_indels$BP), ]
info_indels <- info_indels[order(info_indels$POS), ]
print(paste('same indels postion gwas and geno:', identical(info_indels$POS, gwas_data_indels$BP)))
# combine:
total_info_indels <- data.frame(CHR = info_indels$CHR, POS =info_indels$POS, ID_CMC = info_indels$ID , ID_PGC = gwas_data_indels$SNP, REF = info_indels$REF,
                              ALT = info_indels$ALT, A1 = gwas_data_indels$A1, A2 = gwas_data_indels$A2, ALT_freq =info_indels$ALT_frq, 
                              OR = gwas_data_indels$OR, SE = gwas_data_indels$SE, PVAL= gwas_data_indels$P)
# check ref/alt same as a1/a2 in term of lengths
check_indels <- apply(total_info_indels, 1, check_indels_fun)
if(all(check_indels)){
  print('indels ref/alt same as a1/a2')
}else{
  print('indels ref/alt DIFFERENT from a1/a2, exclude')
  total_info_indels <- total_info_indels[check_indels,]  
}

##### write final ######
# filter geno_dat based on total_info, combine and reorder
geno_dat_snps <- geno_dat_snps[geno_dat_snps$ID %in% total_info_snps$ID_CMC, ]
if(identical(geno_dat_snps$ID, total_info_snps$ID_CMC)){
  print('same snps info and geno order')
}else{
  print('DIFFERENT snps info and geno order, reorder')
  # reorder as in total_info_snps (which is ordered by position)
  id <- sapply(total_info_snps$ID_CMC, function(x) which(x == geno_dat_snps$ID))
  geno_dat_snps <- geno_dat_snps[id,]
}
geno_dat_indels <- geno_dat_indels[geno_dat_indels$ID %in% total_info_indels$ID_CMC, ]
if(identical(geno_dat_indels$ID, total_info_indels$ID_CMC)){
  print('same indels info and geno order')
}else{
  print('DIFFERENT indels info and geno order, reorder')
  # reorder as in total_info_indels (which is ordered by position)
  id <- sapply(total_info_indels$ID_CMC, function(x) which(x == geno_dat_indels$ID))
  geno_dat_indels <- geno_dat_indels[id,]
}

geno_dat <- rbind(geno_dat_snps, geno_dat_indels) 
total_info <- rbind(total_info_snps, total_info_indels)
geno_dat <- geno_dat[order(total_info$POS), ]
total_info <- total_info[order(total_info$POS), ]
print(paste('same final variants info and geno', identical(geno_dat$ID, total_info$ID_CMC)))


## normalize data
#geno_norm <- as.matrix(geno_dat[,-1])
## formula: w(i,j) = (x(i,j)-2p_i)/sqrt(2p_i(1-p_i))
#geno_norm <- apply(geno_norm, 2, function(x) (x-2*info$ALT_frq)/sqrt(2*info$ALT_frq*(1-info$ALT_frq)))
## save
##write.table(x = geno_norm, file = sprintf('%sGenotype_normalized_chr%i_matrix.txt', path_geno, i), col.names = T, row.names = F, sep = '\t', quote = F)
# save varaints positions and info (gwas)
write.table(x = total_info, file = sprintf('%sGenotype_VariantsInfo_CMC-PGC_%s.txt', pathGeno, curChrom), col.names = T, row.names = F, sep = '\t', quote = F)
# save original table
write.table(x = geno_dat[,-1], file = sprintf('%sGenotype_dosage_%s_matrix.txt', pathGeno, curChrom), col.names = T, row.names = F, sep = '\t', quote = F)




