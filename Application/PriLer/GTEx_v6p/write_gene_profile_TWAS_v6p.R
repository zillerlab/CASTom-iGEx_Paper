# prepare TWAs results, save gene results ina unique file
tissues_name <- read.csv('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv', h=F, stringsAsFactors = F)$V1

setwd('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v6p')

for(t in  tissues_name){
  print(t)
  
  tot <- read.table(sprintf('GTEx.%s.pos', t), h=T, stringsAsFactors = F)
  profile <- read.table(sprintf('GTEx.%s.profile', t), h=T, stringsAsFactors = F)
  profile_id <- profile$id
  profile_tab <- data.frame( geneName = tot$ID, ensemble_gene_id = 0, nsnps = NA, hsq=NA, hsq.se=NA,hsq.pv=NA,
                             blup.r2=NA, lasso.r2=NA, enet.r2=NA, bslmm.r2 = NA,  blup.pv=NA, lasso.pv=NA, enet.pv=NA, bslmm.pv = NA, 
                             blup.nsnps = NA, lasso.nsnps=NA, enet.nsnps=NA,  bslmm.nsnps = NA,  stringsAsFactors = F)
  id_col <- unlist(sapply(colnames(profile_tab), function(x) which(colnames(profile) == x)))
  profile <- profile[,id_col]
  
  tmp <- sapply(tot$WGT, function(x) strsplit(x, split = paste0('GTEx.', t,'/','GTEx.', t,'.'))[[1]][2])
  profile_tab$ensemble_gene_id <- mapply(function(x,y) strsplit(x, split = paste0('.', y))[[1]][1], x = tmp, y = profile_tab$geneName, SIMPLIFY = T)
  
  tmp_profile <- sapply(tot$WGT, function(x) strsplit(x, split = paste0('GTEx.', t,'/'))[[1]][2])
  tmp_profile <- sapply(tmp_profile, function(x) strsplit(x, split = '.wgt.RDat')[[1]][1])
  
  for(i in 1:nrow(profile_tab)){
    
    # print(i)
    load(tot$WGT[i])
    # loaded cv.performance hsq hsq.pv snps wgt.matrix
    id <- which(profile_id == tmp_profile[i])
    id_wgt <- unlist(sapply(c('blup', 'lasso' , 'enet', 'bslmm'), function(x) which(x == colnames(wgt.matrix))))
    profile_tab[i,-(c(1:2, 15:18))] <- profile[id,]
    profile_tab[i,paste0(names(id_wgt), '.nsnps')] <- apply(wgt.matrix[, id_wgt],2, function(x) length(which(x!=0)))
    
  }
 
  # save
  write.table(file = sprintf('GTEx.%s/gene.profile', t), x = profile_tab, sep ='\t', col.names = T, row.names = F, quote = F)
  
}