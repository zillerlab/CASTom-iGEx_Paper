library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(igraph)
options(bitmapType = 'cairo', device = 'png')

setwd('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT')
tissues <- read.table('OUTPUT_GTEx/Tissue_CADgwas', h=F, stringsAsFactors = F)$V1
tissues <- tissues[!tissues %in% c('Artery_Tibial', 'Small_Intestine_Terminal_Ileum', 'Stomach', 'Thyroid')]
color_tissues <- read.table('../../castom-igex/Figures/color_tissues.txt', h=T, stringsAsFactors = F)
color_tissues <- color_tissues[match(tissues, color_tissues$tissue), ]
outFold <- 'OUTPUT_GTEx/predict_CAD/AllTissues/200kb/CAD_GWAS_bin5e-2/UKBB/CAD_HARD_clustering/compare_PCs_zcorrPCs_z/'

# compare clustering structure
df_NMI <- data.frame(tissue = tissues, z_vs_zcorrPCs = NA, z_vs_PCs = NA, zcorrPCs_vs_PCs = NA)
df_chisq <- data.frame(tissue = tissues, z_vs_zcorrPCs = NA, z_vs_PCs = NA, zcorrPCs_vs_PCs = NA)
df_cl <-  data.frame(tissue = tissues, z = NA, zcorrPCs = NA, PCs = NA)
test_cv <- list()

out_PC <- get(load('INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/PCs_clusterCases_PGmethod_HKmetric.RData'))
cl_PC <- out_PC$cl_best
cov_test_PC <- out_PC$test_cov

for(i in 1:length(tissues)){
  
  tissue <- tissues[i]
  print(tissue)
  
  file <- sprintf('OUTPUT_GTEx/predict_CAD/%s/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/', tissue)
  out <- get(load(sprintf('%s/tscore_zscaled_clusterCases_PGmethod_HKmetric.RData', file)))
  cl <- out$cl_best
  cov_test <- out$test_cov %>% mutate(type = 'zscaled')
   
  out_cPC <- get(load(sprintf('%s/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData', file)))
  cl_cPC <- out_cPC$cl_best
  cov_test_cPC <- out_cPC$test_cov %>% mutate(type = 'zscaled_corrPCs')
  
  df_NMI$z_vs_zcorrPCs[i] <- compare(cl$gr, cl_cPC$gr, method = 'NMI')
  df_NMI$z_vs_PCs[i] <- compare(cl$gr, cl_PC$gr, method = 'NMI')
  df_NMI$zcorrPCs_vs_PCs[i] <- compare(cl_cPC$gr, cl_PC$gr, method = 'NMI')
  
  df_chisq$z_vs_zcorrPCs[i] <- chisq.test(cl$gr, cl_cPC$gr)$p.value
  df_chisq$z_vs_PCs[i] <- chisq.test(cl$gr, cl_PC$gr)$p.value
  df_chisq$zcorrPCs_vs_PCs[i] <- chisq.test(cl_cPC$gr, cl_PC$gr)$p.value
  
  df_cl$z[i] <- length(unique(cl$gr))
  df_cl$zcorrPCs[i] <- length(unique(cl_cPC$gr))
  df_cl$PCs[i] <- length(unique(cl_PC$gr))
  
  test_cv[[i]] <- bind_rows(cov_test, cov_test_cPC) %>% mutate(tissue = tissue)
  
}

test_cv <- bind_rows(test_cv)
test_cv <- out_PC$test_cov %>% mutate(type = 'PCs', tissue = 'none') %>% bind_rows(test_cv)

# save output
eval_cl <- list(size = df_cl, NMI = df_NMI, chisq = df_chisq, test_cv = test_cv)
save(eval_cl, file = sprintf('%scompare_cl_zscaled_zscaledcorrPCs_PCs.RData', outFold))

### plot n cl ###
n_tissues <- length(tissues)
df_cl_pl <- data.frame(tissue = rep(df_cl$tissue, 2), 
                    n_cl = c(df_cl$z, df_cl$zcorrPCs), 
                    type = c(rep('zscaled', n_tissues), rep('zscaled_corrPCs', n_tissues)))
df_cl_pl$tissue <- factor(df_cl_pl$tissue, levels = rev(tissues))

pl_cl <- ggplot(df_cl_pl, aes(x = tissue, y = n_cl))+
  geom_bar(stat = 'identity', width = 0.5)+
  facet_wrap(.~type, ncol = 2)+
  xlab('') + ylab('n. of groups') + 
  theme_bw() + theme(axis.text.y = element_text(colour = rev(color_tissues$color)))+
  coord_flip()

ggsave(pl_cl, filename = sprintf('%scompare_zscaled_zscaledcorrPCs_ncl.png', outFold),
       width = 5, height = 3, dpi=200)

### plot NMI ###
df_nmi_pl <- data.frame(tissue = rep(df_NMI$tissue, 3), 
                       NMI = c(df_NMI$z_vs_zcorrPCs, df_NMI$z_vs_PCs, df_NMI$zcorrPCs_vs_PCs), 
                       type = c(rep('zscaled vs zscaled_corrPCs', n_tissues), 
                                rep('zscaled vs PCs', n_tissues), 
                                rep('zscaled_corrPCs vs PCs', n_tissues)))

df_nmi_pl$tissue <- factor(df_nmi_pl$tissue, levels = rev(tissues))

pl_NMI <- ggplot(df_nmi_pl, aes(x = tissue, y = NMI))+
  geom_bar(stat = 'identity', width = 0.5)+
  facet_wrap(.~type, ncol = 3, scales = 'free_x')+
  xlab('') + ylab('NMI') + 
  theme_bw() + 
  theme(axis.text.y = element_text(colour = rev(color_tissues$color)), 
        axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_flip()

ggsave(pl_NMI, filename = sprintf('%scompare_zscaled_zscaledcorrPCs_PCs_NMI.png', outFold),
       width = 7.5, height = 3, dpi=200)

### plot chisq ###
df_chisq_pl <- data.frame(tissue = rep(df_chisq$tissue, 3), 
                        chisq_pvalue = c(df_chisq$z_vs_zcorrPCs, df_chisq$z_vs_PCs, df_chisq$zcorrPCs_vs_PCs), 
                        type = c(rep('zscaled vs zscaled_corrPCs', n_tissues), 
                                 rep('zscaled vs PCs', n_tissues), 
                                 rep('zscaled_corrPCs vs PCs', n_tissues)))
df_chisq_pl$chisq_pvalue <- -log10(df_chisq_pl$chisq_pvalue)
df_chisq_pl$tissue <- factor(df_chisq_pl$tissue, levels = rev(tissues))


pl_chisq <- ggplot(df_chisq_pl %>% filter(type != 'zscaled vs zscaled_corrPCs'),
                   aes(x = tissue, y = chisq_pvalue))+
  geom_bar(stat = 'identity', width = 0.5)+
  facet_wrap(.~type, ncol = 3)+
  geom_hline(yintercept = -log10(0.05), linetype = 'dashed', color = 'red')+
  xlab('') + ylab('-log10(p-value) chisquared test') + 
  theme_bw() + 
  theme(axis.text.y = element_text(colour = rev(color_tissues$color)))+
  coord_flip()

ggsave(pl_chisq, filename = sprintf('%scompare_zscaled_zscaledcorrPCs_PCs_chisq.png', outFold),
       width = 5, height = 3, dpi=200)

### plot test cov ###
test_cv  <- test_cv %>% filter(!cov_id %in% c('Batch', 'Array'))
df_cov_pl <-  test_cv %>% filter(!tissue %in% c('none')) %>% mutate(logpval = -log10(pval))

df_cov_pl$tissue <-  factor(df_cov_pl$tissue, levels = tissues)
df_cov_pl$cov_id <- factor(df_cov_pl$cov_id, 
                           levels = rev(c(paste0('PC', 1:10), 'Age', 'Gender', 'initial_assessment_centre')))

pl_cov <- ggplot(df_cov_pl,
                   aes(x = cov_id, y = logpval, fill = type))+
  geom_bar(stat = 'identity', width = 0.8, position = position_dodge2())+
  facet_wrap(.~tissue, ncol = 4)+
  geom_hline(yintercept = -log10(0.05), linetype = 'dashed', color = 'red')+
  xlab('') + ylab('-log10(p-value)') + 
  theme_bw() + theme(legend.position = 'bottom')+
  coord_flip()

ggsave(pl_cov, filename = sprintf('%scompare_zscaled_zscaledcorrPCs_covariates.png', outFold),
       width = 10, height = 7, dpi=200)


################ endophenotypes difference ################

# PCs:
endop_res_PCs1 <- read_tsv('INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/rescaleCont_withMedication_PCs_original_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt')
endop_res_PCs2 <- read_tsv('INPUT_DATA_GTEx/CAD/Covariates/UKBB/CAD_HARD_clustering/rescaleCont_withoutMedication_PCs_original_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt')
endop_res_PCs <- rbind(endop_res_PCs1, endop_res_PCs2)
endop_res_PCs <- endop_res_PCs %>% group_by(comp) %>% 
  mutate(pval_corr = p.adjust(pvalue, method = 'BH')) %>% ungroup()

zscaled <- zscaled_corrPCs <- list()
for(i in 1:length(tissues)){
  
  tissue <- tissues[i]
  print(tissue)
  
  endop_res1 <- read_tsv(sprintf('OUTPUT_GTEx/predict_CAD/%s/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/rescaleCont_withMedication_tscore_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt', tissue))
  endop_res2 <- read_tsv(sprintf('OUTPUT_GTEx/predict_CAD/%s/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/rescaleCont_withoutMedication_tscore_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt', tissue))
  endop_res <- rbind(endop_res1, endop_res2)
  endop_res <- endop_res %>% group_by(comp) %>% 
    mutate(pval_corr = p.adjust(pvalue, method = 'BH'), tissue = tissue) %>% ungroup()
  
  endop_res1_cPC <- read_tsv(sprintf('OUTPUT_GTEx/predict_CAD/%s/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/rescaleCont_withMedication_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt', tissue))
  endop_res2_cPC <- read_tsv(sprintf('OUTPUT_GTEx/predict_CAD/%s/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/rescaleCont_withoutMedication_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt', tissue))
  endop_res_cPC <- rbind(endop_res1_cPC, endop_res2_cPC)
  endop_res_cPC <- endop_res_cPC %>% group_by(comp) %>% 
    mutate(pval_corr = p.adjust(pvalue, method = 'BH')) %>% ungroup()
  
  zscaled[[i]] <- endop_res
  zscaled_corrPCs[[i]] <- endop_res_cPC
}  

plot_comparison <- function(endo1, endo2, endo1_name, endo2_name, tissue){
  
  pheno_id <- intersect(unique(endo1$pheno_id), unique(endo2$pheno_id))
  
  # get best result for each group
  endo1_best <- endo1 %>% 
    group_by(pheno_id) %>%  
    summarise(Field = Field[which.min(pvalue)], meaning = meaning[which.min(pvalue)],
              min_p = min(pvalue), best_z = z[which.min(pvalue)], 
              gr = comp[which.min(pvalue)], BH_corr = pval_corr[which.min(pvalue)] <=0.05) %>%
    mutate(log10p = -log10(min_p)) %>% ungroup(pheno_id)
  
  endo2_best <- endo2 %>% 
    group_by(pheno_id) %>%  
    summarise(Field = Field[which.min(pvalue)], meaning = meaning[which.min(pvalue)],
              min_p = min(pvalue), best_z = z[which.min(pvalue)], 
              gr = comp[which.min(pvalue)], BH_corr = pval_corr[which.min(pvalue)] <=0.05) %>%
    mutate(log10p = -log10(min_p)) %>% ungroup(pheno_id)
  
  combined <- endo1_best %>% full_join(endo2_best, 
                                       c("pheno_id" = "pheno_id")) %>% drop_na(min_p.x) %>% drop_na(min_p.y)
  combined <- combined %>% 
    mutate(label = ifelse(is.na(meaning.x), paste(Field.x),paste(Field.x, meaning.x, sep = '\n'))) 
  combined$sign <- 'FDR > 0.05'
  combined$sign[combined$BH_corr.y] <- sprintf('FDR < 0.05 (%s)', endo2_name)
  combined$sign[combined$BH_corr.x] <- sprintf('FDR < 0.05 (%s)', endo1_name)
  combined$sign[combined$BH_corr.y & combined$BH_corr.x] <- sprintf('FDR < 0.05 (%s & %s)', 
                                                                    endo1_name, endo2_name)
  combined$label_plot <- combined$label
  if(endo1_name == 'PCs'){
    combined$label_plot[!combined$sign %in% c(sprintf('FDR < 0.05 (%s)', endo2_name), 
                                              sprintf('FDR < 0.05 (%s & %s)', endo1_name, endo2_name)) & combined$log10p.x < 5] <- ""
  }else{
    combined$label_plot[!combined$sign %in% c(sprintf('FDR < 0.05 (%s)', endo1_name),
                                              sprintf('FDR < 0.05 (%s)', endo2_name), 
                                              sprintf('FDR < 0.05 (%s & %s)', endo1_name, endo2_name))] <- ""  
  }
  
  combined$sign <- factor(combined$sign, 
                          levels = c( 'FDR > 0.05', sprintf('FDR < 0.05 (%s)', endo1_name),
                                     sprintf('FDR < 0.05 (%s)', endo2_name), 
                                     sprintf('FDR < 0.05 (%s & %s)', endo1_name, endo2_name)))
  
  pl <- ggplot(combined, aes(x = log10p.x, y = log10p.y, color = sign, label = label_plot))+
    geom_vline(xintercept = -log10(0.001), color = 'black', linetype = 'dashed') + 
    geom_hline(yintercept = -log10(0.001), color = 'black', linetype = 'dashed') + 
    geom_point(size = 1) + 
    geom_text_repel(size = 1.5, force = 10)+
    annotate("text", x=-Inf, y=Inf, hjust=-0.2, vjust=1.2, 
             label = paste0("R2 = ", round(cor(combined$log10p.x, combined$log10p.y), digits = 3)))+
    xlab(sprintf('clustering from %s', endo1_name)) + 
    ylab(sprintf('clustering from %s', endo2_name)) + 
    ggtitle(tissue)+
    theme_bw() + theme(legend.position = 'bottom') +
    scale_color_manual(values = c('grey80', 'red', 'blue', 'purple'))
 
  ggsave(pl, filename = sprintf('%s/%s_endophenotype_%s_%s.png', outFold, tissue, endo1_name, endo2_name),
         width = 5, height = 5.5, dpi=200)
  

}

for(i in 1:length(tissues)){
  
  plot_comparison(endo1 = zscaled[[i]], endo2 = zscaled_corrPCs[[i]], tissue = tissues[i],
                  endo1_name = 'zscaled', endo2_name = 'zscaled_corrPCs')  
  
  plot_comparison(endo2 = zscaled[[i]], endo1 = endop_res_PCs,  tissue = tissues[i],
                  endo1_name = 'PCs', endo2_name = 'zscaled')  
  
  plot_comparison(endo2 = zscaled_corrPCs[[i]], endo1 = endop_res_PCs,  tissue = tissues[i],
                  endo1_name = 'PCs', endo2_name = 'zscaled_corrPCs')  
  
}

eval_cl$endop_zscaled <- zscaled
eval_cl$endop_zscaled_corrPCs <- zscaled_corrPCs
eval_cl$endop_PCs <- endop_res_PCs

save(eval_cl, file = sprintf('%scompare_cl_zscaled_zscaledcorrPCs_PCs.RData', outFold))





