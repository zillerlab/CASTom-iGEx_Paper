# modify outcome_info_final_round3_modLT.tsv to include ICD10 and self reported disease and operation
library(data.table)
setwd('/psycl/g/mpsukb/PHESANT/variable-info')
data = fread('outcome_info_final_round3_modLT.tsv', h=T, data.table = F)

# exclude some of the phenotype already processed
# cancer sel reported
id <- c('20001', '84', '20007', '20009', '20006', '20008', '20012', '20013', '20002', '87', '134', '135', '3140') 
data$EXCLUDED[data$FieldID %in% id] <- "YES-ZLAB"

# employment
id <- c('6142', '796', '132', '20024') 
data$EXCLUDED[data$FieldID %in% id] <- "YES-ZLAB"

# diagnosis
id <- c('41201', '41202', '41203', '41204', '41205', '41200', '41210')
data$EXCLUDED[data$FieldID %in% id] <- "YES-ZLAB"

# correct CAT_MULT_INDICATOR_FIELDS 20084, use as field ID 104670
data$CAT_MULT_INDICATOR_FIELDS[data$CAT_MULT_INDICATOR_FIELDS == '20082'] <- '104670'

# correct CAT_MULT_INDICATOR_FIELDS 20400, use as field ID 20499
data$CAT_MULT_INDICATOR_FIELDS[data$CAT_MULT_INDICATOR_FIELDS == '20400'] <- '20499'


fwrite(x = data, file = 'outcome_info_final_round3_modLT_CADrelatedpheno.tsv', col.names = T, sep = '\t', row.names = F, quote = F)
