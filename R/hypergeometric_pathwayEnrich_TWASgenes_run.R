# fisher test to check enrichement

options(stringsAsFactors=F)
options(max.print=1000)
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(dplyr))

parser <- ArgumentParser(description="Pathway enrichment")
parser$add_argument("--tscore_file", type = "character", help = "tscore output combined in a txt")
parser$add_argument("--pathScore_file", type = "character", help = "pathscore output combined in a txt")
parser$add_argument("--type_pathway", type = "character", help = "name of pathway db")
parser$add_argument("--outFold", type = "character", help = "")

args <- parser$parse_args()
tscore_file <- args$tscore_file
pathScore_file <- args$pathScore_file
type_pathway <- args$type_pathway
outFold <- args$outFold

###############################################
# path <- "OUTPUT_GTEx/predict_CAD/AllTissues/200kb/CAD_GWAS_bin5e-2/UKBB/"
# tscore_file <- sprintf("%stscore_pval_CAD_HARD_covCorr.txt", path)
# pathScore_file <- sprintf("%spath_GO_pval_CAD_HARD_covCorr_filt.txt", path)
# type_pathway <- "GO"
# outFold <- "OUTPUT_GTEx/predict_CAD/AllTissues/200kb/CAD_GWAS_bin5e-2/UKBB/"
###############################################                    

### function ###
fisher_test <- function(pathway_to_test, df_twas, var_thr) {
  
  genes_path <- genes %in% strsplit(pathway_to_test$genes_path, split = ',')[[1]]
  fisher_pval <- fisher.test(table(genes_path, df_twas[, var_thr]), alternative = "greater")$p.value
  n_genes_path <- sum(genes_path)
  n_genes_path_sign <- sum(genes_path & df_twas[, var_thr])
  
  return(data.frame(pathway_name = pathway_to_test$path, 
                    genes_path = pathway_to_test$genes_path,
                    n_genes_path = n_genes_path, 
                    n_genes_path_sign = n_genes_path_sign, 
                    TWAS_thr = var_thr,
                    fisher_pval = fisher_pval))
  
}


############ load data #############
tscore <- read.delim(tscore_file, h=T, stringsAsFactors = F, sep = "\t") 
pathScore <- read.delim(pathScore_file, h=T, stringsAsFactors = F, sep = "\t")
BHpval_thr <- c(0.05, 0.1, 0.2)
pval_thr <- c(0.0001, 0.001, 0.01)
#################################################################################

tissues_in_common <- intersect(unique(tscore$tissue), unique(pathScore$tissue))

tscore_tissue <- tscore %>%
  dplyr::filter(tissue %in% tissues_in_common) %>%
  dplyr::arrange(tissue) %>%
  dplyr::group_split(tissue)

pathScore_tissue <- pathScore %>%
  dplyr::filter(tissue %in% tissues_in_common) %>%
  dplyr::arrange(tissue) %>%
  dplyr::group_split(tissue) 

hypgeomtest_output <- list()

for(idx_t in seq_len(length(tscore_tissue))) {
  
  tissue_name <- unique(tscore_tissue[[idx_t]]$tissue)
  print(tissue_name)
  
  genes <- tscore_tissue[[idx_t]]$external_gene_name
  df <- data.frame(genes = genes)
  df <- cbind(df, sapply(BHpval_thr, function(x) genes %in% 
           tscore_tissue[[idx_t]]$external_gene_name[tscore_tissue[[idx_t]][,10] <= x]))
  colnames(df)[-1] <- sprintf("FDR_%s", as.character(BHpval_thr)) 
  df <- cbind(df, sapply(pval_thr, function(x) genes %in% 
                           tscore_tissue[[idx_t]]$external_gene_name[tscore_tissue[[idx_t]][,8] <= x]))
  colnames(df)[-c(1:(length(BHpval_thr)+1))] <- sprintf("pvalue_%s", format(pval_thr, scientific = FALSE)) 
  
  fisher_test_res <- list()
  
  for(idx_thr in colnames(df)[-1]){
    
    print(idx_thr)
    
    fisher_test_res[[idx_thr]] <- lapply(1:nrow(pathScore_tissue[[idx_t]]), function(x)
      fisher_test(pathway_to_test = pathScore_tissue[[idx_t]][x,], 
                  df_twas = df, 
                  var_thr = idx_thr)) %>% 
      dplyr::bind_rows() %>%
      dplyr::mutate(fisher_BHcorr = p.adjust(fisher_pval, method = "BH"))
  }
  
  hypgeomtest_output[[idx_t]] <- dplyr::bind_rows(fisher_test_res) %>%
    dplyr::mutate(tissue = tissue_name)
}

hypgeomtest_output <- dplyr::bind_rows(hypgeomtest_output)

# save output
write.table(x = hypgeomtest_output, 
            file = sprintf("%shyperGeometricTest_TWASgenes_%s.txt", outFold, type_pathway))



