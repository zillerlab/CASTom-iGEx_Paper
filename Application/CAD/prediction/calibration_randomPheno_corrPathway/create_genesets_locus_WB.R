# create custom pathways of low significant genes (P not FDR 0.05 and P < 0.05) 
# located in the same locus
# is the pathway associatio better than single genes?
# all from 1 locus, from 2 loci, from 3 loci etc
# keep same sign

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(rlist))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(dplyr))
options(bitmapType = 'cairo', device = 'png')

fold <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Whole_Blood/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/'
pval_output_file <- sprintf('%s/pval_CAD_pheno_covCorr.RData', fold)
id_pheno <- 1
PriLer_info_file <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/train_GTEx/Whole_Blood/200kb/CAD_GWAS_bin5e-2/resPrior_regEval_allchr.txt'
cis_size <- 200000
bp_loci <- 1000000
tissue_name = 'Whole_Blood'


# load tscore results for CAD:
res_pval <- get(load(pval_output_file))
tscore_res <- res_pval$tscore[[id_pheno]]
# consider only genes significant at least at nominal level:
tscore_res <- tscore_res[tscore_res[,8] <= 0.1, ]
# divide positive/negative zscores:
tscore_res_pos <- tscore_res[tscore_res[,7] > 0,]
tscore_res_neg <- tscore_res[tscore_res[,7] < 0,]


# load priler info file
gene_loc <- fread(PriLer_info_file, data.table = F, stringsAsFactors = F, h=T)
gene_loc <- gene_loc[, 1:9]
gene_loc_filt <- gene_loc[match(tscore_res_pos$ensembl_gene_id, gene_loc$ensembl_gene_id), ]
gene_table_pos <- cbind(gene_loc_filt[,c('type', 'chrom', 'TSS_start', 'start_position', 'end_position')], 
                        tscore_res_pos)
gene_loc_filt <- gene_loc[match(tscore_res_neg$ensembl_gene_id, gene_loc$ensembl_gene_id), ]
gene_table_neg <- cbind(gene_loc_filt[,c('type', 'chrom', 'TSS_start', 'start_position', 'end_position')], 
                        tscore_res_neg)

#### functions ####
merge_loci_genes <- function(gene_table, cis_size, bp_loci, tissue = 'combined'){
  
  tmp <- gene_table
  tmp_loci <- data.frame(chrom = c(), start = c(), end = c(), ngenes = c(), gene = c(), tissue = c())
  
  # divide per chr
  chr_id <- unique(tmp$chrom)
  tmp_chr <- lapply(chr_id, function(x) tmp[tmp$chrom == x,])
  
  for(j in 1:length(chr_id)){
    print(j)
    if(nrow(tmp_chr[[j]]) == 1){
      
      tmp_loci <- rbind(tmp_loci, data.frame(chrom = chr_id[j], start = tmp_chr[[j]]$TSS_start - cis_size, end = tmp_chr[[j]]$TSS_start + cis_size, 
                                             ngenes = 1, gene = tmp_chr[[j]]$external_gene_name, ensembl_gene = tmp_chr[[j]]$ensembl_gene_id,
                                             tissue = tissue))  
    }else{
      
      tmp_chr[[j]] <- tmp_chr[[j]][order(tmp_chr[[j]]$TSS_start), ]
      reg_gene <- data.frame(start = tmp_chr[[j]]$TSS_start - cis_size,  end = tmp_chr[[j]]$TSS_start + cis_size)
      merg_cond <- sapply(reg_gene$end, function(x) abs(x-reg_gene$start) < bp_loci) # the end of the second genes is close to the start of the first gene 1Mb
      
      merge_pos <- lapply(1:nrow(merg_cond), function(x) which(merg_cond[x,]))
      merge_pos_vect <- sapply(merge_pos, function(x) paste0(x, collapse = ','))
      merge_pos_vect <- merge_pos_vect[!duplicated(merge_pos_vect)]
      
      merge_pos <- lapply(merge_pos_vect, function(x) as.numeric(strsplit(x, split = ',')[[1]]))
      new_merge_pos <- list()
      all_merg <- F
      it <- 0
      
      if(length(merge_pos)>1){
        while(!all_merg){
          
          it <- it+1
          # print(it)
          
          for(l in 1:(length(merge_pos)-1)){
            
            if(!all(is.na(merge_pos[[l]]))){
              
              if(all(!merge_pos[[l]] %in% merge_pos[[l+1]])){
                new_merge_pos <- list.append(new_merge_pos, merge_pos[[l]])
              }else{
                if(!(all(merge_pos[[l]] %in% merge_pos[[l+1]]) | all(merge_pos[[l+1]] %in% merge_pos[[l]]))){
                  new_merge_pos <- list.append(new_merge_pos, unique(c(merge_pos[[l]], merge_pos[[l+1]])))
                }else{
                  if(all(merge_pos[[l+1]] %in% merge_pos[[l]])){
                    merge_pos[[l+1]] <- NA
                    new_merge_pos <- list.append(new_merge_pos, merge_pos[[l]])
                  }
                }
              }
              
            }
            
          }
          
          new_merge_pos <- list.append(new_merge_pos, merge_pos[[length(merge_pos)]])
          
          all_merg <- all(!duplicated(unlist(new_merge_pos)))
          merge_pos <- new_merge_pos
          new_merge_pos <- list() 
          
        }
        
        # remove NA
        merge_pos <- merge_pos[!sapply(merge_pos, function(x) all(is.na(x)))]
      }
      tmp_res <-  lapply(merge_pos, function(x) data.frame(chrom = chr_id[j], start = min(tmp_chr[[j]]$TSS_start[x] - cis_size), 
                                                           end = max(tmp_chr[[j]]$TSS_start[x] + cis_size), 
                                                           ngenes = length(x),
                                                           gene = paste0(unique(tmp_chr[[j]]$external_gene_name[x]), collapse = ','), 
                                                           ensembl_gene = paste0(unique(tmp_chr[[j]]$ensembl_gene_id[x]), collapse = ','), 
                                                           tissue = tissue))
      tmp_loci <-  rbind(tmp_loci,do.call(rbind, tmp_res))
      
    }
    
  }
  tmp_loci$start[tmp_loci$start < 0] <- 0
  tmp_loci$loci_id <- paste0(tmp_loci$chrom,':',round(tmp_loci$start/1000000, digits = 1), '-', round(tmp_loci$end/1000000, digits = 1), 'Mb')
  tmp_loci$loci_complete <- paste0(tmp_loci$chrom,':',tmp_loci$start,'-',tmp_loci$end)
  
  return(tmp_loci)
}

# annotate locus for all genes
tscore_loci_pos <- merge_loci_genes(gene_table = gene_table_pos,
                                    cis_size = cis_size, bp_loci = bp_loci, 
                                    tissue = tissue_name)

tscore_loci_neg <- merge_loci_genes(gene_table = gene_table_neg,
                                    cis_size = cis_size, bp_loci = bp_loci, 
                                    tissue = tissue_name)

# create new pathway structure:
tscore_loci_keep <- rbind(tscore_loci_pos, tscore_loci_pos)
tscore_loci_keep <- tscore_loci_keep %>% filter(ngenes > 2)
custom_path <- list()
for(i in 1:nrow(tscore_loci_keep)){
  
  custom_path[[i]] <- list(name = sprintf('gene set locus %i', i), 
                           geneIds = strsplit(tscore_loci_keep$gene[i], split = ',')[[1]])
  
}

# save 
save(custom_path, file = sprintf('%sgeneSets_sameLocus_sameSign.RData', fold))

#### save loci per genes in whole blood (all)
tscore_tot <- res_pval$tscore[[id_pheno]]
gene_loc_filt <- gene_loc[match(tscore_tot$ensembl_gene_id, gene_loc$ensembl_gene_id), ]
gene_table <- cbind(gene_loc_filt[,c('type', 'chrom', 'TSS_start', 'start_position', 'end_position')], 
                        tscore_tot)

tscore_loci_tot <- merge_loci_genes(gene_table = gene_table,
                                    cis_size = cis_size, bp_loci = bp_loci, 
                                    tissue = tissue_name)

write.table(tscore_loci_tot, file = sprintf('%sloci_all_genes.txt', fold), 
            quote = F, col.names = T, row.names = F, sep = '\t')


