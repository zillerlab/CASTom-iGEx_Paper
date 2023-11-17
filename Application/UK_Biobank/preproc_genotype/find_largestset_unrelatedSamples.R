library(igraph)

# remove duplicated or relatives from ukbb
sample_ID = read.table('/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/ukb34217_imp_chr1_v3_s487317.filtered.sample', h=T, stringsAsFactors=F)
sample_ID <- sample_ID[-1, ]
relatives_tab = read.table('/psycl/g/mpsziller/lucia/UKBB/phenotype_data/ukb34217_rel_s488282.dat', h=T, stringsAsFactors=F)
sample_ID_split <- read.table('/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/split_samples_ukb34217', h=F, stringsAsFactors = F)

# filter relatives based on samples in sample_ID
all_rel <- unique(c(relatives_tab$ID1, relatives_tab$ID2))
all_rel_filt <- all_rel[all_rel %in% sample_ID$ID_1]

relatives_tab_filt <- relatives_tab[relatives_tab$ID1 %in% all_rel_filt & relatives_tab$ID2 %in% all_rel_filt, ]
df <- relatives_tab_filt[, c('ID1', 'ID2', 'Kinship')]
graph_rel <- graph_from_data_frame(df, directed = F, vertices = NULL)
families <-  groups(components(graph_rel))

exclude <- vector(mode = 'list', length = length(families))
for(i in 1:length(families)){
  
  print(paste('family:', i))
  
  tmp <- families[[i]]
  
  if(length(tmp)>=100){
    exclude[[i]] <- c()
    # due to memory issue impossibile to compute, remove the most connected node and try again
    while(length(tmp)>=100){
      new_gr <- induced_subgraph(graph_rel, tmp)
      edges_V_f <- sapply(V(new_gr), function(x) length(incident(new_gr, x, mode='total')))
      rm_node <- names(which.max(edges_V_f))
      exclude[[i]] <- c(exclude[[i]], rm_node)
      new_fam <- setdiff(tmp, rm_node)
      graph_new_fam <- induced_subgraph(graph_rel, new_fam)
      new_fam_sub <- groups(components(graph_new_fam))
      
      id <- which(sapply(new_fam_sub, length)<100 & sapply(new_fam_sub, length)>1)
      if(length(id)>0){
        for(j in 1:length(id)){
          keep <- names(largest_ivs(induced_subgraph(graph_rel, new_fam_sub[[id[j]]]))[[1]])  
          exclude[[i]] <- c(exclude[[i]], setdiff(new_fam_sub[[id[j]]], keep))
        }
      }
      
      if(any(sapply(new_fam_sub, length)>=100)){
        tmp <- unlist(new_fam_sub[which(sapply(new_fam_sub, length)>=100)])
      }else{
        tmp <- 0
      }
      print(length(tmp))
    }
    
  }else{
    
    keep <- names(largest_ivs(induced_subgraph(graph_rel, tmp))[[1]])
    exclude[[i]] <- setdiff(families[[i]], keep)   
    
  }
  
 
}

exclude <- unlist(exclude)
# save list of samples to exclude
id <- sapply(exclude, function(x) which(x == sample_ID$ID_1))
df_excl <- data.frame(ID_1 = exclude, ID_2 = sample_ID$ID_2[id])

write.table(x = df_excl, file = '/psycl/g/mpsukb/UKBB_hrc_imputation/relatives_toremove_filtered_white_british_34217.txt', col.names = F, row.names = F, quote = F)

sample_ID_split_filt <- sample_ID_split[!sample_ID_split$V1 %in% df_excl$ID_1,]
write.table(x = sample_ID_split_filt, file = '/psycl/g/mpsukb/UKBB_hrc_imputation/oxford/split_samples_unrelated_ukb34217', col.names = F, row.names = F, quote = F)
