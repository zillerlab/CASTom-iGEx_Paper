# convert db files downloaded from prediXcan
library('RSQLite')

tissues_name <- read.csv('/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/final_model_gtex.csv', h=F, stringsAsFactors = F)$V1

sqlite.driver <- dbDriver("SQLite")

prediXcan_v6p <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prediXcan/GTEx_v6p/'
for(t in  tissues_name){
  
  db <- dbConnect(sqlite.driver, dbname = sprintf('%s/TW_%s/TW_%s_0.5.db', prediXcan_v6p,t, t))  
  list_table <- dbListTables(db)
  extra <- dbReadTable(db,'extra')
  sample_info <- dbReadTable(db,'sample_info')
  
  # save
  write.table(file = sprintf('%s/TW_%s/extra.txt', prediXcan_v6p, t), x = extra, col.names = T, row.names = F, sep = '\t', quote = F)
  write.table(file = sprintf('%s/TW_%s/sample_info.txt', prediXcan_v6p, t), x = sample_info, col.names = T, row.names = F, sep = '\t', quote = F)
  
  dbDisconnect(db)
}

prediXcan_v7 <- '/psycl/g/mpsziller/lucia/PriLer_PROJECT_GTEx/INPUT_DATA/prediXcan/GTEx_v7/'
for(t in  tissues_name){
  
  db <- dbConnect(sqlite.driver, dbname = sprintf('%s/%s/gtex_v7_%s_imputed_europeans_tw_0.5_signif.db', prediXcan_v7, t, t))  
  list_table <- dbListTables(db)
  extra <- dbReadTable(db,'extra')
  sample_info <- dbReadTable(db,'sample_info')
  
  # save
  write.table(file = sprintf('%s/%s/extra.txt', prediXcan_v7, t), x = extra, col.names = T, row.names = F, sep = '\t', quote = F)
  write.table(file = sprintf('%s/%s/sample_info.txt', prediXcan_v7, t), x = sample_info, col.names = T, row.names = F, sep = '\t', quote = F)
  
  dbDisconnect(db)
}
