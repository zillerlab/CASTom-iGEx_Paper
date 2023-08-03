# build SNP-epi annotation matrix
options(stringsAsFactors=F)
options(max.print=1000)
library(Matrix)
library(argparse)


parser <- ArgumentParser(description="Compute dist SNP GRE for all chr, correct range for the new peak files if needed")

parser$add_argument("--VarInfo_file", type = "character", help = "SNPs info file")
parser$add_argument("--peak_files", type = "character", nargs = '*', help = "peak files additional")
parser$add_argument("--names_peak", type = "character", nargs = '*', help = "peak files additional")
parser$add_argument("--GRElib_file", type = "character", help = "multiple peaks file")
parser$add_argument("--perc_thr", type = "double", default = 0.4, help = "percentage of peak wrt to baseline, threshold to increase the window")
parser$add_argument("--outFold", type = "character", help = "output folder")

args <- parser$parse_args()
VarInfo_file <- args$VarInfo_file
outFold <- args$outFold
peak_files <- args$peak_files
names_peak <- args$names_peak
perc_thr <- args$perc_thr
GRElib_file <- args$GRElib_file

# #####################################################################################################
# outFold <- '/ziller/lucia/eQTL_PROJECT_CMC/OUTPUT_CMC_SCRIPTS_v1/'
# VarInfo_file <- '/ziller/lucia/eQTL_PROJECT_CMC/INPUT_DATA_SCRIPTS_v1/Genotyping_data/Genotype_VariantsInfo_CMC-PGC_'
#  peak_files <- c('/ziller/Michael/All_PeakFiles/FinalIDR_FPC_neuronal_ATAC_R2_macs2.bed', '/ziller/Michael/All_PeakFiles/FinalIDR_FPC_neuronal_ATAC_R4_macs2.bed',
# '/ziller/lucia/datasets/hg19_Ctrl_150_allPeaks_cellRanger.bed')
# names_peak <- c('FPC_neuronal_ATAC_R2', 'FPC_neuronal_ATAC_R4', 'Ctrl_150_allPeaks_cellRanger')
# perc_thr <- 0.4
# GRElib_file <- '/ziller/GRE_library/H3K27ac_v2/hg19.1.H3K27ac_GRElibrary_v2_rpkm_quantile_95th_binary.txt'
# #####################################################################################################

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


for(chr in all_Chroms){
  
  
  print(paste('########## chr', chr, '############'))
  
  # load filtered SNP list
  snpTab <- read.table(sprintf('%schr%s.txt', VarInfo_file, chr), header = T, stringsAsFactors = F)
  id <- which(sapply(colnames(snpTab), function(x) strsplit(x, split = 'ID')[[1]][1] == ''))
  tmp <- snpTab[,which(colnames(snpTab) %in% c('CHR', 'POS'))]
  tmp <- cbind(tmp, tmp[,2] +1, snpTab[, id])
  colnames(tmp) <- c("chrom","chromstart","chromend",names(id))
  tmp$chrom <- sprintf('chr%s',tmp$chrom)
  
  curPeak <- GRElib[GRElib[,1]==paste0('chr', chr),]
  curPeak_add <- lapply(peak, function(x)  x[x$chrom == paste0('chr', chr),])
  
  curSnps <- tmp
  curAnn <- cbind(curSnps, matrix(0, nrow = nrow(curSnps), ncol = ncol(GRElib) - 4 + length(curPeak_add)))
  colnames(curAnn) <- c(colnames(curSnps), colnames(GRElib)[5:ncol(GRElib)], names_peak)
  
  # curPeak_CAD <- CAD_GRElib[CAD_GRElib[,1]==chromList[i],]
  
  id <- sapply(1:nrow(curSnps), function(x){
    id_r <- which(curSnps[x,2] <= curPeak$chromend & curSnps[x,2]>= curPeak$chromstart)
    # if(length(id_r)==0){id_r <- 0}
    return(id_r)})
  
  id_peak_add <- lapply(curPeak_add, function(y) sapply(1:nrow(curSnps), function(x){
    id_r <- which(curSnps[x,2] <= y$chromend & curSnps[x,2] >= y$chromstart)
    return(id_r)}))
  
  
  # reassign, if more than 1 region contain the same snp, merge the annotation
  index_id_add <- list()
  for(i in 1:length(names_peak)){
    index_id_add[[i]] <-  which(sapply(id_peak_add[[i]], function(x) length(x)>0))
    curAnn[index_id_add[[i]], colnames(curAnn) == names_peak[i]] <- 1
  }
  
  index_id <- which(sapply(id, function(x) length(x)>0))
  curAnn[index_id, (ncol(curSnps)+1):(ncol(curAnn)-length(names_peak))] <- t(sapply(index_id, function(x) colSums(curPeak[id[[x]],5:ncol(curPeak)])))
  # if there are values higher than 1, reassign
  id_sub <- apply(curAnn[,(ncol(curSnps)+1):(ncol(curAnn)-length(names_peak))], 2, function(x) which(x>1))
  
  for(j in 1:length(id_sub)){
    curAnn[id_sub[[j]],(j+5)] <- 1
  }
  
  # save 
  write.table(curAnn,paste0(outFold, "/hg19_SNPs-Epi_chr",chr,"_matched.txt"),sep="\t",quote=F,row.names=F, col.names = T)
  system(paste("gzip",paste0(outFold, "/hg19_SNPs-Epi_chr",chr,"_matched.txt")))
  
}









