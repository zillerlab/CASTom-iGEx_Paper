# simulate T-scores from a multivariate normal distribution with decided correlation

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(tibble))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(mvtnorm))
options(bitmapType = 'cairo', device = 'png')

pheno_file <- 'INPUT_DATA_GTEx/CAD/Covariates/UKBB/phenoMatrix_updateCADHARD.txt'
cov_file <- 'INPUT_DATA_GTEx/CAD/Covariates/UKBB/covariateMatrix_latestW.txt'
outFold <- 'OUTPUT_GTEx/predict_CAD/simulation_pathway/'

covDat <- fread(cov_file, h=T, stringsAsFactors = F, sep = '\t', data.table = F)
phenoDat <- fread(pheno_file, h=T, stringsAsFactors = F, sep = '\t', data.table = F)
phenoDat <- phenoDat[match(covDat$Individual_ID, phenoDat$Individual_ID),]
pheno_var <- phenoDat$CAD_HARD

n_genes <- 10
n_samples <- 10000 #n_samples <- length(pheno_var)
sigma_single <- 1
prob_pos <- sum(pheno_var)/length(pheno_var)

corr_thr <- seq(0, 1, by = 0.1)
remove_genes_seq <- 0:n_genes
effect_size_concordant <- rep(0.15, n_genes)
effect_size_opposite <- c(rep(0.15, n_genes/2), rep(-0.15, n_genes/2))
n_rep <- 100

########## functions ###########
simulate_genes <- function(n_genes, max_corr, min_corr, sigma, remove_corr = 0){
  
  corr_unif <- runif(min = min_corr, max = max_corr, n = (n_genes-1)*n_genes/2)
  var_sim <- rep(sigma_single, n_genes)
  corr_mat <- diag(x = 0, nrow = n_genes)
  corr_mat[lower.tri(corr_mat, diag = F)] <- corr_unif
  corr_mat <- corr_mat + t(corr_mat)
  if(remove_corr>0){
    corr_mat[,1:remove_corr] <- 0
    corr_mat[1:remove_corr,] <- 0
  }
  corr_mat <- corr_mat + diag(1, nrow = n_genes)
  
  # convert from correlation to covariance
  cov_mat <- sweep(corr_mat,MARGIN=2,sqrt(var_sim),"*")
  cov_mat <- sweep(cov_mat,MARGIN=1,sqrt(var_sim),"*")
  
  # simulate tscores:
  tscores_sim <- rmvnorm(n = n_samples, mean = rep(0,n_genes), sigma = cov_mat)
  
  return(tscores_sim)
  
}

generate_phenotype <- function(effect_size, prob, tscores){
  
  beta0 <- log(prob/(1-prob))
  n_genes <- ncol(tscores)
  n_samples <- nrow(tscores)
  
  effect_size <- matrix(effect_size, nrow = 1)
  # simulate log ODDs ratio
  eta = beta0 +  tscores %*% t(effect_size)
  p = 1 / (1 + exp(-eta))
  y = rbinom(n = n_samples, size = 1, prob = p)
  
  return(y)
}

extract_output <- function(var_id, df){
  
  # var_id <- paste0('X',id_gene)
  fmla <- paste0('y ~ ', var_id)
  fmla <- as.formula(fmla)
  
  res <- glm(fmla, data = df, family = 'binomial')
  output <- coef(summary(res))[rownames(coef(summary(res))) == var_id,1:4]
  
  return(output)
  
}

simulation_and_regression_v1 <- function(n_genes, corr_thr, effect_size, sigma_single, 
                                         n_samples, prob_pos, seed){
  
  res <- list()
  for(i in 1:(length(corr_thr) -1)){
    
    set.seed(seed + i)
    tscores_sim <- simulate_genes(n_genes = n_genes, sigma = sigma_single,
                                  max_corr = corr_thr[i+1], 
                                  min_corr = corr_thr[i])
    
    pheno_sim <- generate_phenotype(effect_size = effect_size, prob = prob_pos, tscores = tscores_sim)
    
    # combine
    df <- data.frame(y=pheno_sim, tscores_sim)
    df$path <- rowMeans(df[, paste0('X', 1:n_genes)])
    
    reg_genes <- t(sapply(1:n_genes, function(x) extract_output(paste0('X',x), df)))
    reg_path <- extract_output('path', df)
    reg_output <- data.frame(id = c(paste0('X', 1:n_genes), 'gene_set'), rbind(reg_genes, reg_path))
    rownames(reg_output) <- NULL
    colnames(reg_output) <- c('id', 'beta', 'se_beta', 'z', 'pvalue')
    
    res[[i]] <- reg_output
    res[[i]]$corr_thr <- paste0(corr_thr[i], '-', corr_thr[i+1])
    
  }
  
  
  res <- do.call(rbind, res)
  return(res)
  
}


simulation_and_regression_v2 <- function(n_genes, corr_thr, effect_size, sigma_single, 
                                         n_samples, prob_pos, seed, remove_genes_seq){
  
  res <- list()
  for(i in 1:length(remove_genes_seq)){
    
    set.seed(seed + i)
    tscores_sim <- simulate_genes(n_genes = n_genes, sigma = sigma_single,
                                  max_corr = corr_thr[2], 
                                  min_corr = corr_thr[1], 
                                  remove_corr = remove_genes_seq[i])
    
    pheno_sim <- generate_phenotype(effect_size = effect_size, prob = prob_pos, tscores = tscores_sim)
    
    # combine
    df <- data.frame(y=pheno_sim, tscores_sim)
    df$path <- rowMeans(df[, paste0('X', 1:n_genes)])
    
    reg_genes <- t(sapply(1:n_genes, function(x) extract_output(paste0('X',x), df)))
    reg_path <- extract_output('path', df)
    reg_output <- data.frame(id = c(paste0('X', 1:n_genes), 'gene_set'), rbind(reg_genes, reg_path))
    rownames(reg_output) <- NULL
    colnames(reg_output) <- c('id', 'beta', 'se_beta', 'z', 'pvalue')
    
    res[[i]] <- reg_output
    res[[i]]$n_genes_corr <- n_genes - remove_genes_seq[i]
    
  }
  
  
  res <- do.call(rbind, res)
  return(res)
  
}

compute_differences_rep <- function(id_type, output_table, n_rep, n_genes){
  
  id_var <- 'id'
  diff_z <- list()
  for(id_rep in 1:n_rep){
    
    res <- output_table[[id_rep]]
    
    type_all <- unique(res[, id_type])
    var_all <- unique(res[, id_var])
    
    diff_z[[id_rep]] <- data.frame(type = type_all, mean_diff = 0,gene_set_z= 0)
    
    for(i in 1:length(type_all)){
      tmp <- res[res[, id_type] == type_all[i],]
      z_genes <- tmp[tmp[,id_var] != 'gene_set', 'z']
      # T_stat[i] <- sqrt(n_genes)*(mean(z_genes) - tmp[tmp[,id_var] == 'gene_set', 'z'])/sd(z_genes)
      diff_z[[id_rep]]$mean_diff[i] <- mean(tmp[tmp[,id_var] == 'gene_set', 'z'] - z_genes)
      diff_z[[id_rep]]$gene_set_z[i] <- tmp[tmp[,id_var] == 'gene_set', 'z']
    }
    diff_z[[id_rep]]$rep <- id_rep
    
  }
  
  diff_z <- do.call(rbind, diff_z)
  
  return(diff_z)
}
#################################

concordant_beta_v1 <- lapply(1:n_rep, function(x) 
  simulation_and_regression_v1(n_genes = n_genes, effect_size = effect_size_concordant, 
                               sigma_single = sigma_single, n_samples = n_samples, prob_pos = prob_pos, 
                               seed = 10*x, corr_thr = corr_thr))

opposite_beta_v1 <-  lapply(1:n_rep, function(x) 
  simulation_and_regression_v1(n_genes = n_genes, effect_size = effect_size_opposite, 
                               sigma_single = sigma_single, n_samples = n_samples, prob_pos = prob_pos, 
                               seed = 10*x, corr_thr = corr_thr))

print('Version 1 completed')


concordant_beta_v2 <- lapply(1:n_rep, function(x) 
  simulation_and_regression_v2(n_genes = n_genes, effect_size = effect_size_concordant, 
                               sigma_single = sigma_single, n_samples = n_samples, prob_pos = prob_pos, 
                               seed = 10*x+10000, corr_thr = c(0.9, 1),  remove_genes_seq = remove_genes_seq))

opposite_beta_v2 <-  lapply(1:n_rep, function(x) 
  simulation_and_regression_v2(n_genes = n_genes, effect_size = effect_size_opposite, 
                               sigma_single = sigma_single, n_samples = n_samples, prob_pos = prob_pos, 
                               seed = 10*x+10000, corr_thr = c(0.9, 1), remove_genes_seq = remove_genes_seq))

print('Version 2 completed')

#################################

# convert to differences
diff_concordant_beta_v1 <- compute_differences_rep(id_type = 'corr_thr', 
                        output_table = concordant_beta_v1, 
                        n_rep = n_rep, n_genes = n_genes)

diff_opposite_beta_v1 <- compute_differences_rep(id_type = 'corr_thr', 
                                                   output_table = opposite_beta_v1, 
                                                   n_rep = n_rep, n_genes = n_genes)


diff_concordant_beta_v2 <- compute_differences_rep(id_type = 'n_genes_corr', 
                                                   output_table = concordant_beta_v2, 
                                                   n_rep = n_rep, n_genes = n_genes)

diff_opposite_beta_v2 <- compute_differences_rep(id_type = 'n_genes_corr', 
                                                 output_table = opposite_beta_v2, 
                                                 n_rep = n_rep, n_genes = n_genes)

output <- list(concordant_beta_v1 = diff_concordant_beta_v1, 
               opposite_beta_v1 = diff_opposite_beta_v1, 
               concordant_beta_v2 = diff_concordant_beta_v2, 
               opposite_beta_v2 = diff_opposite_beta_v2)

save(output, file = sprintf('%ssimulation_tscores_varying_corr.RData', outFold))
