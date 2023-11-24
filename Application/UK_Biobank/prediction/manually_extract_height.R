# obtain height from weight and BMI:
# reason: not requested, if possible use original

library(data.table)

dat_file <- '/psycl/g/mpsziller/lucia/UKBB/phenotype_data/Schunkert_phenotype_CAD/Phenotype_2017_ID10089/ukb10089.tab'
outFold <- '/psycl/g/mpsziller/lucia/UKBB/phenotype_data/'
expl_var <- '/psycl/g/mpsukb/PHESANT/variable-info/outcome_info_final_round3_modLT.tsv'

df_name <- data.frame(name = c('Body mass index (BMI)', 'Weight'), stringsAsFactors = F)
expl_var <- read.delim(expl_var, h=T, stringsAsFactors = F, sep = '\t')
df_name$id <- expl_var$FieldID[match(df_name$name, expl_var$Field)]

df_new <- data.frame(name = c('Height'), 
                     id = c('12144der'))
df_new$formula <- c('sqrt(21002/21001)')


id_column <- c('f.eid', 'f.31.0.0', 'f.21022.0.0', 
               as.vector(sapply(as.character(df_name$id), function(x) c(sprintf('f.%s.0.0', x), sprintf('f.%s.1.0', x), sprintf('f.%s.2.0', x)))))
tot_dat <- fread(dat_file, h=T, stringsAsFactors = F, sep = '\t', select = id_column, data.table = F)
new_dat <-tot_dat[, c('f.eid', 'f.31.0.0', 'f.21022.0.0')]


id_rep <- c('.0.0', '.1.0', '.2.0')
tmp <- sapply(id_rep, function(x) sqrt(tot_dat[, sprintf('f.%s%s', '21002', x)]/tot_dat[, sprintf('f.%s%s','21001', x)]))
tmp[is.infinite(tmp)] <- NA
colnames(tmp) <- paste0('f.', df_new$id, id_rep)
tmp <- as.data.frame(tmp)
new_dat <- cbind(new_dat, tmp)
  
fwrite(x = new_dat, file = sprintf('%sukb10089_HeightDer.tab', outFold), quote = F, col.names = T, sep = '\t', row.names = F)

# save expl_var new
expl_var_new <- data.frame(FieldID =  df_new$id, TRAIT_OF_INTEREST = "", EXCLUDED = "", CAT_MULT_INDICATOR_FIELDS = "", 
                           CAT_SINGLE_TO_CAT_MULT = "", DATA_CODING = NA, Path = 'NA > NA > NA > Height derived', Category = 'created', 
                           Field = df_new$name, Participants = NA, Items = NA,Stability = 'Complete',  ValueType = 'Continuous', Units = 'meter', 
                           ItemType = 'Data', Strata = 'Primary', Sexed = 'Unisex', Instances = 3, Array = 1, Coding = NA, Notes = 'manually created from BMI and weight', 
                           Link = NA)
expl_var_new <- rbind(expl_var, expl_var_new)

fwrite(x = expl_var_new, file = '/psycl/g/mpsukb/PHESANT/variable-info/outcome_info_round3_modLT_plus_height.tsv', quote = F, col.names = T, sep = '\t', row.names = F)


