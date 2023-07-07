# find common set of SNPs and filter based on MAF and INFO

options(stringsAsFactors=F)
options(max.print=1000)
library(argparse)

parser <- ArgumentParser(description="Filter .gen file")

parser$add_argument("--path_info", type = "character", help = "pathway .gen_info file")
parser$add_argument("--path_gen", type = "character", help = "pathway gen file")
parser$add_argument("--chr", type = "character", help = "chromosome considered")
parser$add_argument("--MAF_thr", type = "double",default = 0.05, help = "threshold to filter snps based on MAF")
parser$add_argument("--INFO_thr", type = "double",default = 0.8, help = "threshold to filter snps based on INFO")
parser$add_argument("--outf", type="character", help = "Output file [basename only]")

args <- parser$parse_args()
path_info <- args$path_info
path_gen <- args$path_gen
MAF_thr <- args$MAF_thr
INFO_thr <- args$INFO_thr
chr <- args$chr
outFold <- args$outf

##############################################################################################

gen_info <- read.table(sprintf('%s%s/%s_ALL.gen_info', path_info, chr, chr), header = T, stringsAsFactors = F)
# concatenated file, corrected
gen_info <- gen_info[gen_info$exp_freq_a1 != 'exp_freq_a1',]
gen_info$exp_freq_a1 <- as.numeric(gen_info$exp_freq_a1)
gen_info$info <- as.numeric(gen_info$info)
gen_info$position <- as.integer(gen_info$position)
# merge with path_gen
gen <- read.table(sprintf('%stmp_%s', path_gen, chr), header = F, stringsAsFactors = F)
# mere based on both position and ID (some names are not defined for indels or snps)
tmp <- gen_info[gen_info$rs_id %in% gen$V2,]
if(nrow(tmp) != nrow(gen)){
  toadd <- gen[!gen$V2 %in% tmp$rs_id,][which(gen$V3[!gen$V2 %in% tmp$rs_id] %in% gen_info$position),]
  gen_info_part <- gen_info[gen_info$position %in% toadd$V3,]
  gen_info_part <- gen_info_part[gen_info_part$rs_id == '.',]
  gen_info_part$rs_id <- sapply(gen_info_part$position, function(x) gen$V2[gen$V3 ==x])
  tmp <- rbind(tmp,gen_info_part)
}
gen_info <- tmp 
# check all the correct snps are there
print(paste("correct filtering:",all(gen_info$rs_id %in% gen$V2)))

id <- sort(union(which(gen_info$exp_freq_a1>1-MAF_thr | gen_info$exp_freq_a1<MAF_thr), which(gen_info$info<INFO_thr)))
snps_id_filt <- gen_info$rs_id[id]

write.table(x = data.frame(snps_id_filt, stringsAsFactors = F), file = sprintf('%svar_toremove_%s', outFold, chr), quote = F, sep ='\t', row.names = F, col.names = F)


