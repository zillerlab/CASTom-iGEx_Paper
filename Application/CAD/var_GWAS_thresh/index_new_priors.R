c <- "/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/PriLer_PROJECT_GTEx"
l <- "/scratch/tmp/dolgalev/castom-igex-revision/PriLer_PROJECT_GTEx"

all_priors <- read.table(
  paste0(c, "/OUTPUT_SCRIPTS_v2/allPriorName.txt"),
  sep = "\t",
  header = 0,
  row.names = 1
)

new_priors <- data.frame(
  V2 = c(
    "CAD_gwas_bin_p00001", "CAD_gwas_bin_p0001", "CAD_gwas_bin_p001", "CAD_gwas_bin_p005", "CAD_gwas_bin_p01",
    "PGC_gwas_bin_p00001", "PGC_gwas_bin_p0001", "PGC_gwas_bin_p001", "PGC_gwas_bin_p005", "PGC_gwas_bin_p01"
  )
)

all_priors <- rbind(all_priors, new_priors)

write.table(
  all_priors,
  paste0(l, "/OUTPUT_SCRIPTS_v2/allPriorName_gwas_thresh.txt"),
  sep = "\t",
  col.names = FALSE,
  quote = FALSE
)
