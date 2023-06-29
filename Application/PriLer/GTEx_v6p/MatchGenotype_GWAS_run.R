# prepare input file,
# write genotype dosage in the correct order and info
# match with gwas file

options(max.print=1000)
options(stringsAsFactors = F)
library(Matrix)
library(argparse)

parser <- ArgumentParser(description="write genotype in the correct format, match with GWAS")

parser$add_argument("--nameGeno", type = "character", help = "path to dosage genotype data")
parser$add_argument("--nameInfo", type = "character", help = "path to genotype info and sample file")
parser$add_argument("--nameGWAS_CAD", type = "character", help = "path to gwas PGC")
parser$add_argument("--nameGWAS_PGC", type = "character", help = "path to gwas CAD")
parser$add_argument("--curChrom", type = "character", help = "chromosome considered")
parser$add_argument("--outFold", type = "character", help = "path to output folder")

args <- parser$parse_args()
nameInfo <- args$nameInfo
nameGeno <- args$nameGeno
nameGWAS_CAD <- args$nameGWAS_CAD
nameGWAS_PGC <- args$nameGWAS_PGC
curChrom <- args$curChrom
outFold <- args$outFold

# ##########################
# nameInfo <- '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/phg000520.v2.GTEx_MidPoint_Imputation.genotype-calls-vcf.c1/GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_chr'
# nameGeno <- '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/GTEx_v6p/phg000520.v2.GTEx_MidPoint_Imputation.genotype-calls-vcf.c1/GTEx_Analysis_20150112_OMNI_2.5M_5M_450Indiv_chr1to22_genot_imput_info04_maf01_HWEp1E6_ConstrVarIDs_chr'
# nameGWAS_CAD <- '/mnt/lucia/datasets/CAD_GWAS/cad.add.160614.website_chr'
# nameGWAS_PGC <- '/mnt/lucia/datasets/PGC_GWAS/Original_SCZ_variants_chr'
# curChrom <- 'chr1'
# outFold <- '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/GTEx/Genotype_data/'
# ##########################


###########################
# function to check indel annotation
check_indels_fun <- function(x){
  x <- unlist(x)
  x <- x[6:9]
  x <- x[nchar(x)>1] # first ref or alt, second a1 or a2
  res <- unname(nchar(x[1]) == as.numeric(strsplit(x[2], split = 'I')[[1]][2]))
  return(res)
}
###########################

### load datasets ###
chr <- strsplit(curChrom, split = 'chr')[[1]][2]
# gwas
pgc_gwas <- read.table(sprintf('%s%s.txt', nameGWAS_PGC, chr), header = F, stringsAsFactors = F)
cad_gwas <- read.table(sprintf('%s%s.txt', nameGWAS_CAD, chr), header = F, stringsAsFactors = F)
colnames(pgc_gwas) <- c('CHR', 'SNP', 'A1', 'A2', 'BP', 'info', 'OR', 'SE', 'P', 'ngt')
colnames(cad_gwas) <- c('markername',	'chr'	,'bp_hg19',	'effect_allele'	,'noneffect_allele',	'effect_allele_freq',	'median_info',	'model',	'beta',	'se_dgc',	'p_dgc'	,'het_pvalue'	,
                        'n_studies')

# geno
geno_dat <- read.table(sprintf('%s%s_filt_matrixeQTL.geno', nameGeno, chr), header = F, sep = '\t', stringsAsFactors = F)
geno_info <- read.table(sprintf('%s%s_filt.gen_info', nameInfo, chr), header = F, sep = ' ', stringsAsFactors = F)
geno_sample <- read.table(sprintf('%s%s_filt.sample', nameInfo, chr), header = T, sep = ' ', stringsAsFactors = F)

######################################## NOTE ########################################
# an "error" occured in the first step of the pipeline, 
# some samples are named "1" due to the presence on a underscore in the original name (plink2 warnings)
# reconstruct the original name from the .sample file
######################################################################################
geno_sample <- geno_sample[-1,]
newAnn <- paste(geno_sample$ID_1[geno_sample$ID_2 == "1"], geno_sample$ID_2[geno_sample$ID_2 == "1"], sep = '_')
sample_names <- geno_sample$ID_2
sample_names[which(sample_names == "1")] <- newAnn

colnames(geno_info) <- c('CHROM', 'ID' ,'POS' ,'REF', 'ALT' ,'EXP_FREQ_A1' ,'IMPINFO' ,'HW')
colnames(geno_dat) <- c('ID', sample_names)

# divide SNP from indels in geno_dat and info
id_snps <- nchar(geno_info$REF) == 1 & nchar(geno_info$ALT) == 1 
info_snps <- geno_info[id_snps,]
info_indels <- geno_info[!id_snps,]


###### match gwas data and geno ######
# use position, name con be different 
## snps
pgc_gwas_snps <-  pgc_gwas[!(pgc_gwas$A1 == 'D'|pgc_gwas$A2 == 'D'), ] 
cad_gwas_snps <-  cad_gwas[!(cad_gwas$effect_allele == 'D'|cad_gwas$noneffect_allele == 'D'), ]
# there could be repeated position (error, deleate them)
info_snps <- info_snps[!info_snps$POS %in% names(which(table(info_snps$POS)>1)), ]


pos_snps <- intersect(info_snps$POS, pgc_gwas_snps$BP)
pos_snps <- intersect(pos_snps,  cad_gwas_snps$bp_hg19)
print(paste('all SNP position in geno:', all(info_snps$POS %in% pos_snps)))

info_snps <- info_snps[info_snps$POS %in% pos_snps, ]
pgc_gwas_snps <- pgc_gwas_snps[pgc_gwas_snps$BP %in% pos_snps, ]
cad_gwas_snps <-  cad_gwas_snps[cad_gwas_snps$bp_hg19 %in% pos_snps, ] 

pgc_gwas_snps <- pgc_gwas_snps[order(pgc_gwas_snps$BP), ]
cad_gwas_snps <- cad_gwas_snps[order(cad_gwas_snps$bp_hg19), ]
info_snps <- info_snps[order(info_snps$POS), ]

print(paste('SNP postion CAD, PGC and geno:', nrow(pgc_gwas_snps), nrow(cad_gwas_snps), nrow(info_snps)))
print(paste('identical SNP position CAD and PGC:', identical(pgc_gwas_snps$BP, cad_gwas_snps$bp_hg19)))
print(paste('identical SNP position geno and PGC:', identical(pgc_gwas_snps$BP, info_snps$POS)))

# combine:
total_info_snps <- data.frame(CHR = info_snps$CHR, POS = info_snps$POS, ID_CMC = info_snps$ID , ID_PGC = pgc_gwas_snps$SNP, ID_CAD = cad_gwas_snps$markername, 
                              REF = info_snps$REF, ALT = info_snps$ALT, PGC_A1 = pgc_gwas_snps$A1, PGC_A2 = pgc_gwas_snps$A2, CAD_EffAll = cad_gwas_snps$effect_allele, CAD_nonEffAll = cad_gwas_snps$noneffect_allele, 
                              EXP_FREQ_A1_GTEx = info_snps$EXP_FREQ_A1, 
                              PGC_OR = pgc_gwas_snps$OR, PGC_SE = pgc_gwas_snps$SE, PGC_PVAL= pgc_gwas_snps$P, 
                              CAD_beta = cad_gwas_snps$beta, CAD_se_dgc = cad_gwas_snps$se_dgc, CAD_p_dgc = cad_gwas_snps$p_dgc)

# check ref/alt same as a1/a2
check_snps_pgc <- apply(total_info_snps, 1, function(x) all(x[6:7] %in% x[8:9]))
if(all(check_snps_pgc)){
  print('SNP ref/alt same as a1/a2 (PGC)')
}else{
  print('SNP ref/alt DIFFERENT from a1/a2  (PGC), exclude')
  total_info_snps <- total_info_snps[check_snps_pgc,]  
}

check_snps_cad <- apply(total_info_snps, 1, function(x) all(x[6:7] %in% x[10:11]))
if(all(check_snps_cad)){
  print('SNP ref/alt same as eff_a/not_eff_a (CAD)')
}else{
  print('SNP ref/alt DIFFERENT from eff_a/not_eff_a (CAD), exclude')
  total_info_snps <- total_info_snps[check_snps_cad,]  
}


## indels
pgc_gwas_indels <- pgc_gwas[pgc_gwas$A1 == 'D'|pgc_gwas$A2 == 'D',]
# remove deletion/duplication
pgc_gwas_indels <- pgc_gwas_indels[sapply(pgc_gwas_indels$SNP, function(x) strsplit(x, split = '_')[[1]][1]) != 'MERGED',]
cad_gwas_indels <-  cad_gwas[cad_gwas$effect_allele == 'D'|cad_gwas$noneffect_allele == 'D', ]

# there could be repeated position (error, deleate them)
info_indels <- info_indels[!info_indels$POS %in% names(which(table(info_indels$POS)>1)), ]

pos_indels <- intersect(info_indels$POS, pgc_gwas_indels$BP)
pos_indels <- intersect(pos_indels,  cad_gwas_indels$bp_hg19)

print(paste('all INDEL position in geno:', all(info_indels$POS %in% pos_indels)))

pgc_gwas_indels <-  pgc_gwas_indels[pgc_gwas_indels$BP %in% pos_indels, ] # dimension can be different, some snps present
cad_gwas_indels <-  cad_gwas_indels[cad_gwas_indels$bp_hg19 %in% pos_indels, ] # dimension can be different, some snps present
info_indels <- info_indels[info_indels$POS %in% pos_indels, ]

pgc_gwas_indels <- pgc_gwas_indels[order(pgc_gwas_indels$BP), ]
cad_gwas_indels <- cad_gwas_indels[order(cad_gwas_indels$bp_hg19), ]
info_indels <- info_indels[order(info_indels$POS), ]

print(paste('INDEL postion CAD, PGC and geno:', nrow(pgc_gwas_indels), nrow(cad_gwas_indels), nrow(info_indels)))
print(paste('identical INDEL position CAD and PGC:', identical(pgc_gwas_indels$BP, cad_gwas_indels$bp_hg19)))
print(paste('identical INDEL position geno and PGC:', identical(pgc_gwas_indels$BP, info_indels$POS)))

# combine:
total_info_indels <- data.frame(CHR = info_indels$CHR, POS = info_indels$POS, ID_CMC = info_indels$ID , ID_PGC = pgc_gwas_indels$SNP, ID_CAD = cad_gwas_indels$markername, 
                              REF = info_indels$REF, ALT = info_indels$ALT, PGC_A1 = pgc_gwas_indels$A1, PGC_A2 = pgc_gwas_indels$A2, CAD_EffAll = cad_gwas_indels$effect_allele, CAD_nonEffAll = cad_gwas_indels$noneffect_allele, 
                              EXP_FREQ_A1_GTEx = info_indels$EXP_FREQ_A1, 
                              PGC_OR = pgc_gwas_indels$OR, PGC_SE = pgc_gwas_indels$SE, PGC_PVAL= pgc_gwas_indels$P, 
                              CAD_beta = cad_gwas_indels$beta, CAD_se_dgc = cad_gwas_indels$se_dgc, CAD_p_dgc = cad_gwas_indels$p_dgc)


# check ref/alt same as a1/a2 in term of lengths (only for PGC, CAD doesn't have the length info)
check_indels <- apply(total_info_indels, 1, check_indels_fun)
if(all(check_indels)){
  print('INDEL ref/alt same as a1/a2 (PGC)')
}else{
  print('INDEL ref/alt DIFFERENT from a1/a2 (PGC), exclude')
  total_info_indels <- total_info_indels[check_indels,]  
}

##### write final ######
# filter geno_dat based on total_info, combine and reorder
geno_dat_snps <- geno_dat[geno_dat$ID %in% total_info_snps$ID_CMC, ]
if(identical(geno_dat_snps$ID, total_info_snps$ID_CMC)){
  print('same SNP info and geno order')
}else{
  print('DIFFERENT SNP info and geno order, reorder')
  # reorder as in total_info_snps (which is ordered by position)
  id <- sapply(total_info_snps$ID_CMC, function(x) which(x == geno_dat_snps$ID))
  geno_dat_snps <- geno_dat_snps[id,]
}
geno_dat_indels <- geno_dat[geno_dat$ID %in% total_info_indels$ID_CMC, ]
if(identical(geno_dat_indels$ID, total_info_indels$ID_CMC)){
  print('same INDEL info and geno order')
}else{
  print('DIFFERENT INDEL info and geno order, reorder')
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
write.table(x = total_info, file = sprintf('%sGenotype_VariantsInfo_CMC-PGCgwas-CADgwas_%s.txt', outFold, curChrom), col.names = T, row.names = F, sep = '\t', quote = F)

# save original table
write.table(x = geno_dat[,-1], file = sprintf('%sGenotype_dosage_%s_matrix.txt', outFold, curChrom), col.names = T, row.names = F, sep = '\t', quote = F)
system(paste("gzip", sprintf('%sGenotype_dosage_%s_matrix.txt', outFold, curChrom)))




