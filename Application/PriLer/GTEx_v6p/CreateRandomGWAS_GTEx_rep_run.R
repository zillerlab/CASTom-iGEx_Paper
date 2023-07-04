# create random GWAS statistic based on PGC distribution
options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(simGWAS))
suppressPackageStartupMessages(library(mvtnorm))
suppressPackageStartupMessages(library(corpcor))

parser <- ArgumentParser(description="generate random GWAS info per chr")

parser$add_argument("--curChrom", type = "integer", help = "chromosome")
parser$add_argument("--VarInfo_file", type = "character", help = "variants info, complete path")
parser$add_argument("--N_samples", type = "integer",nargs = '*', default = c(40000, 30000), help = "number of controls and cases")
parser$add_argument("--seeds", type = "integer",nargs = '*', default = c(42, 50, 1234), help = "random seeds")
parser$add_argument("--n_rep", type = "integer",default = 10, help = "number of repetition for the simulation")
parser$add_argument("--outFold", type="character", help = "Output file [basename only]")

args <- parser$parse_args()
curChrom <- args$curChrom
VarInfo_file <- args$VarInfo_file
N_samples <- args$N_samples
seeds <- args$seeds
n_rep <- args$n_rep
outFold <- args$outFold

############################################################
# N_samples = c(45000, 35000)
# curChrom <- 22
# n_rep <- 10
# seeds <-  c(42, 50, 1234)
# outFold <- '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Genotype_data/randomGWAS/'
# VarInfo_file <- '/mnt/lucia/eQTL_PROJECT_GTEx/INPUT_DATA/Genotype_data/Genotype_VariantsInfo_CMC-PGCgwas-CADgwas_'
############################################################
# load temporary results
load(sprintf('%stmpFile_chr%s.RData', outFold, curChrom))

# match with SNP info
var_info <- read.table(sprintf('%schr%i.txt', VarInfo_file, curChrom), header = T, stringsAsFactors = F)
var_info_sing <- var_info[var_info$POS %in% names(which(table(var_info$POS)==1)),]

var_info_filt <- tmp$var_info_filt
dfsnps <- tmp$dfsnps
freq <- tmp$freq

rm(tmp)

g1_PGC_tot <- var_info_filt$PGC_OR
g1_CAD_tot <- exp(var_info_filt$CAD_beta)

# high effect
g1_CAD_h = g1_CAD_tot[g1_CAD_tot<=0.96 | g1_CAD_tot>=1.04]
g1_PGC_h = g1_PGC_tot[g1_PGC_tot<=0.96 | g1_PGC_tot>=1.04]
# medium effect
g1_CAD_m = g1_CAD_tot[g1_CAD_tot<=0.97 | g1_CAD_tot>=1.03]
g1_PGC_m = g1_PGC_tot[g1_PGC_tot<=0.97 | g1_PGC_tot>=1.03]
# low effect
g1_CAD_l = g1_CAD_tot[g1_CAD_tot<=0.98 | g1_CAD_tot>=1.02]
g1_PGC_l = g1_PGC_tot[g1_PGC_tot<=0.98 | g1_PGC_tot>=1.02]

fin_tab <- vector(mode = 'list', length = n_rep)

for(j in 1:n_rep){
  
  print(j)
  
  # create windows of random size
  cond <- F
  count <- 0
  id_pos_PGC <- list()
  id_fin <- 0
  
  while(!cond){
    
    count <- count+1
    set.seed(seeds[1]*count*curChrom*j)
    nlen <- sample(100:2000, 1)
    id_pos_PGC[[count]] <- (id_fin+1):(id_fin+nlen)
    id_fin <- max(id_pos_PGC[[count]])
    print(id_fin)
    
    cond <- max(id_fin>nrow(dfsnps))
  }
  
  id_pos_PGC[[length(id_pos_PGC)]] <- id_pos_PGC[[length(id_pos_PGC)]][id_pos_PGC[[length(id_pos_PGC)]] <= nrow(dfsnps)]
  if(length(id_pos_PGC[[length(id_pos_PGC)]])<=50){
    id_pos_PGC[[length(id_pos_PGC)-1]] <- sort(c(id_pos_PGC[[length(id_pos_PGC)-1]], id_pos_PGC[[length(id_pos_PGC)]]))
    id_pos_PGC[[length(id_pos_PGC)]] <- NULL
  }
  
  
  # create windows of random size
  cond <- F
  count <- 0
  id_pos_CAD <- list()
  id_fin <- 0
  
  while(!cond){
    
    count <- count+1
    set.seed(seeds[1]*count*curChrom*j+1000)
    nlen <- sample(100:2000, 1)
    id_pos_CAD[[count]] <- (id_fin+1):(id_fin+nlen)
    id_fin <- max(id_pos_CAD[[count]])
    print(id_fin)
    
    cond <- max(id_fin>nrow(dfsnps))
  }
  
  id_pos_CAD[[length(id_pos_CAD)]] <- id_pos_CAD[[length(id_pos_CAD)]][id_pos_CAD[[length(id_pos_CAD)]] <= nrow(dfsnps)]
  
  if(length(id_pos_CAD[[length(id_pos_CAD)]])<=50){
    id_pos_CAD[[length(id_pos_CAD)-1]] <- sort(c(id_pos_CAD[[length(id_pos_CAD)-1]], id_pos_CAD[[length(id_pos_CAD)]]))
    id_pos_CAD[[length(id_pos_CAD)]] <- NULL
  }
  
  PVAL_CAD_sim <- vector(mode = 'list', length = length(id_pos_CAD))
  PVAL_PGC_sim <- vector(mode = 'list', length = length(id_pos_PGC))
  
  for(i in 1:length(id_pos_PGC)){
    
    print(i)
    
    tmp_id <- id_pos_PGC[[i]]
    print(length(tmp_id))
    dfsnps_tmp <- dfsnps[tmp_id, ]
    
    # var_info_tmp <- var_info[var_info$POS %in% dfsnps_tmp$position,]
    cond <- ifelse(length(tmp_id)<700, T, F)
    if(cond){
      set.seed(seeds[2]*curChrom*j+i)
      cond <- sample(x = c(T,F), 1, prob = c(0.6, 0.4))
    }
    
    freq_tmp <- freq[, tmp_id]
    freq_tmp$Probability <- 1/nrow(freq_tmp)
    
    
    if(cond){
      
      PVAL_PGC_sim[[i]] <- matrix(ncol=3, nrow = length(tmp_id))
      
      set.seed(seeds[3]*i*curChrom*j)
      g1_PGC_sample_l <- sample(g1_PGC_l,sample(1:5, 1))
      set.seed(seeds[3]*i*curChrom*j+1)
      g1_PGC_sample_m <- sample(g1_PGC_m,sample(1:5, 1))
      set.seed(seeds[3]*i*curChrom*j+2)
      g1_PGC_sample_h <- sample(g1_PGC_h,sample(1:5, 1))
      
      #g1 <- rnorm(n=sample(1:5, 1), mean = 1, sd = 0.03)
      print(g1_PGC_sample_l)
      print(g1_PGC_sample_m)
      print(g1_PGC_sample_h)
      
      CV <- sample(which(dfsnps_tmp$EUR > 0.05 & dfsnps_tmp$EUR < 0.95),length(g1_PGC_sample_l))
      # compute simulated beta and SE
      FP <- make_GenoProbList(snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], freq=freq_tmp)
      ## method 1 - simulate Z scores and adjust by expected variance to get beta
      EZ <- simGWAS:::est_statistic(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs,W=dfsnps_tmp$rs[CV], gamma.W=log(g1_PGC_sample_l), freq=freq_tmp, GenoProbList=FP) 
      valt <- expected_vbeta(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], gamma.W=log(g1_PGC_sample_l), freq=freq_tmp, GenoProbList=FP)
      Ebeta <- EZ * valt
      PVAL_PGC_sim[[i]][,1] <- pnorm(-abs(EZ))*2
      
      CV <- sample(which(dfsnps_tmp$EUR > 0.05 & dfsnps_tmp$EUR < 0.95),length(g1_PGC_sample_m))
      # compute simulated beta and SE
      FP <- make_GenoProbList(snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], freq=freq_tmp)
      ## method 1 - simulate Z scores and adjust by expected variance to get beta
      EZ <- simGWAS:::est_statistic(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs,W=dfsnps_tmp$rs[CV], gamma.W=log(g1_PGC_sample_m), freq=freq_tmp, GenoProbList=FP) 
      valt <- expected_vbeta(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], gamma.W=log(g1_PGC_sample_m), freq=freq_tmp, GenoProbList=FP)
      Ebeta <- EZ * valt
      PVAL_PGC_sim[[i]][,2] <- pnorm(-abs(EZ))*2
      
      CV <- sample(which(dfsnps_tmp$EUR > 0.05 & dfsnps_tmp$EUR < 0.95),length(g1_PGC_sample_h))
      # compute simulated beta and SE
      FP <- make_GenoProbList(snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], freq=freq_tmp)
      ## method 1 - simulate Z scores and adjust by expected variance to get beta
      EZ <- simGWAS:::est_statistic(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs,W=dfsnps_tmp$rs[CV], gamma.W=log(g1_PGC_sample_h), freq=freq_tmp, GenoProbList=FP) 
      valt <- expected_vbeta(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], gamma.W=log(g1_PGC_sample_h), freq=freq_tmp, GenoProbList=FP)
      Ebeta <- EZ * valt
      PVAL_PGC_sim[[i]][,3] <- pnorm(-abs(EZ))*2
      
      
    }else{
      
      print('not casual pvalues')
      LD <- cor(freq_tmp[, -ncol(freq_tmp)]) 
      LD <- as.matrix(make.positive.definite(LD)) 
      
      set.seed(seeds[3]*i*curChrom*j)
      tmp <- rmvnorm(n = 3, mean = rep(0, length(tmp_id)), sigma = LD)
      PVAL_PGC_sim[[i]] <- t(pnorm(-abs(tmp))  * 2)
      
    }
    
  }
  
  
  for(i in 1:length(id_pos_CAD)){
    
    print(i)
    
    tmp_id <- id_pos_CAD[[i]]
    print(length(tmp_id))
    dfsnps_tmp <- dfsnps[tmp_id, ]
    
    # var_info_tmp <- var_info[var_info$POS %in% dfsnps_tmp$position,]
    cond <- ifelse(length(tmp_id)<700, T, F)
    if(cond){
      set.seed(seeds[2]*curChrom*j+i+1000)
      cond <- sample(x = c(T,F), 1, prob = c(0.6, 0.4))
    }
    
    freq_tmp <- freq[, tmp_id]
    freq_tmp$Probability <- 1/nrow(freq_tmp)
    
    
    if(cond){
      
      PVAL_CAD_sim[[i]] <- matrix(ncol=3, nrow = length(tmp_id))
      
      ####
      set.seed(seeds[3]*i*curChrom*j+1000)
      g1_CAD_sample_l <- sample(g1_CAD_l,sample(1:5, 1))
      set.seed(seeds[3]*i*curChrom*j+1000+1)
      g1_CAD_sample_m <- sample(g1_CAD_m,sample(1:5, 1))
      set.seed(seeds[3]*i*curChrom*j+1000+2)
      g1_CAD_sample_h <- sample(g1_CAD_h,sample(1:5, 1))
      
      print(g1_CAD_sample_l)
      print(g1_CAD_sample_m)
      print(g1_CAD_sample_h)
     
      CV <- sample(which(dfsnps_tmp$EUR > 0.05 & dfsnps_tmp$EUR < 0.95), length(g1_CAD_sample_l))
      # compute simulated beta and SE
      FP <- make_GenoProbList(snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], freq=freq_tmp)
      ## method 1 - simulate Z scores and adjust by expected variance to get beta
      EZ <- simGWAS:::est_statistic(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], gamma.W=log(g1_CAD_sample_l), freq=freq_tmp,GenoProbList=FP) 
      valt <- expected_vbeta(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], gamma.W=log(g1_CAD_sample_l), freq=freq_tmp, GenoProbList=FP) 
      Ebeta <- EZ * valt
      PVAL_CAD_sim[[i]][,1] <- pnorm(-abs(EZ))*2
      
      CV <- sample(which(dfsnps_tmp$EUR > 0.05 & dfsnps_tmp$EUR < 0.95),length(g1_CAD_sample_m))
      # compute simulated beta and SE
      FP <- make_GenoProbList(snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], freq=freq_tmp)
      ## method 1 - simulate Z scores and adjust by expected variance to get beta
      EZ <- simGWAS:::est_statistic(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], gamma.W=log(g1_CAD_sample_m), freq=freq_tmp,GenoProbList=FP) 
      valt <- expected_vbeta(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], gamma.W=log(g1_CAD_sample_m), freq=freq_tmp, GenoProbList=FP) 
      Ebeta <- EZ * valt
      PVAL_CAD_sim[[i]][,2] <- pnorm(-abs(EZ))*2
      
      CV <- sample(which(dfsnps_tmp$EUR > 0.05 & dfsnps_tmp$EUR < 0.95),length(g1_CAD_sample_h))
      # compute simulated beta and SE
      FP <- make_GenoProbList(snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], freq=freq_tmp)
      ## method 1 - simulate Z scores and adjust by expected variance to get beta
      EZ <- simGWAS:::est_statistic(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], gamma.W=log(g1_CAD_sample_h), freq=freq_tmp,GenoProbList=FP) 
      valt <- expected_vbeta(N0=N_samples[1], N1=N_samples[2], snps=dfsnps_tmp$rs, W=dfsnps_tmp$rs[CV], gamma.W=log(g1_CAD_sample_h), freq=freq_tmp, GenoProbList=FP) 
      Ebeta <- EZ * valt
      PVAL_CAD_sim[[i]][,3] <- pnorm(-abs(EZ))*2
      
    }else{
      
      print('not casual pvalues')
      LD <- cor(freq_tmp[, -ncol(freq_tmp)]) 
      LD <- as.matrix(make.positive.definite(LD)) 
      
      set.seed(seeds[3]*i*curChrom*j+1000)
      tmp <- rmvnorm(n = 3, mean = rep(0, length(tmp_id)), sigma = LD)
      PVAL_CAD_sim[[i]] <- t(pnorm(-abs(tmp))  * 2)
      
    }
    
  }
  
  
  PVAL_PGC_fin <- do.call(rbind, PVAL_PGC_sim)
  PVAL_CAD_fin <- do.call(rbind, PVAL_CAD_sim)
  
  # adjust for missing positions
  df_fin <- var_info
  df_fin$PVAL_PGC_random_lE <- NA
  df_fin$PVAL_PGC_random_mE <- NA
  df_fin$PVAL_PGC_random_hE <- NA
  df_fin$PVAL_CAD_random_lE <- NA
  df_fin$PVAL_CAD_random_mE <- NA
  df_fin$PVAL_CAD_random_hE <- NA
  
  df_fin$PVAL_PGC_random_lE[df_fin$ID_PGC %in% var_info_filt$ID_PGC] <- PVAL_PGC_fin[,1]
  tmp <- runif(n=length(which(is.na(df_fin$PVAL_PGC_random_lE))), min = 0, max = 1)
  df_fin$PVAL_PGC_random_lE[is.na(df_fin$PVAL_PGC_random_lE)] <- tmp
  
  df_fin$PVAL_PGC_random_mE[df_fin$ID_PGC %in% var_info_filt$ID_PGC] <- PVAL_PGC_fin[,2]
  tmp <- runif(n=length(which(is.na(df_fin$PVAL_PGC_random_mE))), min = 0, max = 1)
  df_fin$PVAL_PGC_random_mE[is.na(df_fin$PVAL_PGC_random_mE)] <- tmp
  
  df_fin$PVAL_PGC_random_hE[df_fin$ID_PGC %in% var_info_filt$ID_PGC] <- PVAL_PGC_fin[,3]
  tmp <- runif(n=length(which(is.na(df_fin$PVAL_PGC_random_hE))), min = 0, max = 1)
  df_fin$PVAL_PGC_random_hE[is.na(df_fin$PVAL_PGC_random_hE)] <- tmp
  
  df_fin$PVAL_CAD_random_lE[df_fin$ID_PGC %in% var_info_filt$ID_PGC] <- PVAL_CAD_fin[,1]
  tmp <- runif(n=length(which(is.na(df_fin$PVAL_CAD_random_lE))), min = 0, max = 1)
  df_fin$PVAL_CAD_random_lE[is.na(df_fin$PVAL_CAD_random_lE)] <- tmp
  
  df_fin$PVAL_CAD_random_mE[df_fin$ID_PGC %in% var_info_filt$ID_PGC] <- PVAL_CAD_fin[,2]
  tmp <- runif(n=length(which(is.na(df_fin$PVAL_CAD_random_mE))), min = 0, max = 1)
  df_fin$PVAL_CAD_random_mE[is.na(df_fin$PVAL_CAD_random_mE)] <- tmp
  
  df_fin$PVAL_CAD_random_hE[df_fin$ID_PGC %in% var_info_filt$ID_PGC] <- PVAL_CAD_fin[,3]
  tmp <- runif(n=length(which(is.na(df_fin$PVAL_CAD_random_hE))), min = 0, max = 1)
  df_fin$PVAL_CAD_random_hE[is.na(df_fin$PVAL_CAD_random_hE)] <- tmp
  
  if(j==1){
    png(sprintf('%s/plot_comparison_random_PGC_chr%i.png', outFold, curChrom), width = 1000, height = 1500)
    par(mfrow = c(4,1))
    plot(-log10(df_fin$PGC_PVAL), pch=20)
    plot(-log10(df_fin$PVAL_PGC_random_lE), pch=20, col = 'orange')
    plot(-log10(df_fin$PVAL_PGC_random_mE), pch=20, col='red')
    plot(-log10(df_fin$PVAL_PGC_random_hE), pch=20, col='purple')
    dev.off()
    
    png(sprintf('%s/plot_comparison_random_CAD_chr%i.png', outFold, curChrom), width = 1000, height = 1500)
    par(mfrow = c(4,1))
    plot(-log10(df_fin$CAD_p_dgc), pch=20)
    plot(-log10(df_fin$PVAL_CAD_random_lE), pch=20, col = 'orange')
    plot(-log10(df_fin$PVAL_CAD_random_mE), pch=20, col='red')
    plot(-log10(df_fin$PVAL_CAD_random_hE), pch=20, col='purple')
    dev.off()
    
  }
  
  fin_tab[[j]] <- df_fin[, colnames(df_fin) %in% c('PVAL_PGC_random_lE','PVAL_PGC_random_mE','PVAL_PGC_random_hE', 'PVAL_CAD_random_lE',  'PVAL_CAD_random_mE',  'PVAL_CAD_random_hE')]
  colnames(fin_tab[[j]]) <- sapply(colnames(fin_tab[[j]]), function(x) paste0(x,'_', 'r', j))
    
}

df_tot <- cbind(df_fin[, colnames(df_fin) %in% c('CHR','POS','ID_CMC','ID_PGC','ID_CAD','REF','ALT','PGC_PVAL','CAD_p_dgc')], do.call(cbind, fin_tab))

# save final result
write.table(file = sprintf('%s/randomGWAS_PVAL_PGC-CAD_chr%i.txt', outFold, curChrom), x = df_tot, col.names = T, row.names = F, sep = '\t', quote = F)
system(paste("gzip", sprintf('%s/randomGWAS_PVAL_PGC-CAD_chr%i.txt', outFold, curChrom)))

