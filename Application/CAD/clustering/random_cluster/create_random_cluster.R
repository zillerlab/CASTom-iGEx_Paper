# create random clustering:
fold <- '/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/'
clust_res <- get(load(sprintf('%stscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric.RData', fold)))
n_rep <- 50
cl <-  clust_res$cl_best$gr
  
for(i in 1:n_rep){
  
  set.seed(345+i)
  
  tmp <- sample(cl, replace = F)
  output <- list(feat = clust_res$feat, res_pval = clust_res$res_pval, 
                 samples_id = clust_res$samples_id, 
                 cl_best = data.frame(id = clust_res$cl_best$id, gr = tmp))
  
  file_name <- sprintf('%srandom_cluster/tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_rep%i.RData', fold, i)
  save(output, file = file_name)
}
