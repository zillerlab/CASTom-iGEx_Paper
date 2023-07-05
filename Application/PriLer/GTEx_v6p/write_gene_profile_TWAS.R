# prepare TWAs results, save gene results ina unique file
tissues_name <- read.csv('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv', h=F, stringsAsFactors = F)$V1

setwd('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/TWAS/GTEx_v7')

for(t in  tissues_name){
  print(t)
  
  tot <- read.table(sprintf('%s.P01.pos', t), h=T, stringsAsFactors = F)
  profile_tab <- data.frame( geneName = tot$ID, ensemble_gene_id = 0, nsnps = 0, hsq=0, hsq.se=0,hsq.pv=0,
                             blup.r2=0, lasso.r2=0, enet.r2=0,  blup.pv=0, lasso.pv=0, enet.pv=0, blup.nsnps = 0, lasso.nsnps=0, enet.nsnps=0, stringsAsFactors = F)
  
  tmp <- sapply(tot$WGT, function(x) strsplit(x, split = paste0(t,'/',t,'.'))[[1]][2])
  profile_tab$ensemble_gene_id <- sapply(tmp, function(x) strsplit(x, split = '.wgt.RDat')[[1]][1])
  
  for(i in 1:nrow(profile_tab)){
    
    # print(i)
    load(tot$WGT[i])
    # loaded cv.performance hsq hsq.pv N.tot snps wgt.matrix
    profile_tab[i,-(1:2)] <- c(nrow(snps), hsq, hsq.pv, as.vector(t(cv.performance[, c('blup', 'lasso' , 'enet')])), 
                               apply(wgt.matrix[, c('blup', 'lasso' , 'enet')],2, function(x) length(which(x!=0))))
  }
 
  # save
  write.table(file = sprintf('%s/gene.profile', t), x = profile_tab, sep ='\t', col.names = T, row.names = F, quote = F)
  
}
