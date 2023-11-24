# modify outcome_info_final_round3_modLT.tsv to include ICD10 and self reported disease and operation
library(data.table)
setwd('/psycl/g/mpsukb/PHESANT/variable-info')
data = fread('outcome_info_final_round3_modLT.tsv', h=T, data.table = F)

field_mod <- c('20002', '20004', '41202', '41204', '40006', '40013', '41203', '41205', '41200', '41210')
data$CAT_MULT_INDICATOR_FIELDS[data$FieldID %in% field_mod] <- 'ALL'
data$EXCLUDED[data$FieldID %in% field_mod] <- ""

# auxiliary variables tp be included and used as covariates:
field_mod <- c('396', '397', '4250', '4253', '12651', '20200', '20229', '22661', '25756', '25757', '25758', '25759')
data$EXCLUDED[data$FieldID %in% field_mod] <- ""

fwrite(x = data, file = 'outcome_info_final_round3_modLT.tsv', col.names = T, sep = '\t', row.names = F, quote = F)
