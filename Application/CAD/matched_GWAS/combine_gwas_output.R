# combine GWAS results and correct pval
library(data.table)
library(dplyr)

setwd('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GWAS/')

id_chr <- 1:22
gwas_output <- list()
for(id_chr in 1:22){
  
  print(id_chr)
  tmp <- fread(sprintf('chr%i/CAD_UKBB_chr%i.PHENO1.glm.logistic', id_chr, id_chr),
               h=T, stringsAsFactors=F, data.table = F)
  
  tmp_add <- tmp %>% 
             rename(CHROM = '#CHROM') %>%
             filter(TEST == 'ADD') %>%
             mutate(P = as.numeric(P))
   
  gwas_output[[id_chr]] <- tmp_add
  
}

gwas_output <- do.call(rbind, gwas_output)

# correct
gwas_output$P_ADJ_BONF <- p.adjust(gwas_output$P, method = 'bonferroni')
gwas_output$P_ADJ_BH <- p.adjust(gwas_output$P, method = 'BH')

# save
write.table(x = gwas_output, file = 'CAD_UKBB_logistic_gwas_summary.txt', col.names = T, 
            row.names = F, sep = '\t', quote = F)
