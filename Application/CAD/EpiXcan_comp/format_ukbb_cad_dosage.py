from datetime import datetime
from pathlib import Path

import pigz_python as pigz
import polars as pl


cad_dir = '/cloud/wwu1/h_fungenpsy/AGZiller_data/CASTOMiGEx/CAD_UKBB/eQTL_PROJECT/INPUT_DATA_GTEx/CAD'
ukbb_cov_dir = f'{cad_dir}/Covariates/UKBB'
ukbb_genotype_dir = f'{cad_dir}/Genotyping_data/UKBB'
sdata_dir = '/scratch/tmp/dolgalev/castom-igex-revision/epixcan/data/ukbb'


samples = (
    pl.read_csv(f'{ukbb_cov_dir}/covariateMatrix_latestW_202304.txt', separator='\t')
    .get_column('genoSample_ID')
    .cast(str)
)


split = range(1, 101)
chrom = range(1, 23)

chr_var_list = []


for c in chrom:
    chr_var = pl.read_csv(
        f'{ukbb_genotype_dir}/UKBB.Genotype_VariantsInfo_matchedCADall-UKBB-GTEx_chr{c}.txt',
        separator='\t',
        columns=[0, 2, 3, 4, 5, 6]  # Drop 'ID' column
    )

    chr_var_list.append(chr_var)


for s in split:
    for c in chrom:
        s_dosage = pl.read_csv(f'{ukbb_genotype_dir}/Genotype_dosage_split{s}_chr{c}_matrix.txt.gz', separator='\t')

        s_dosage = s_dosage.select(col.name for col in s_dosage if col.name in samples)  # Filter UKBB samples

        
        if c == 1:
            Path(f'{sdata_dir}/split{s}').mkdir(parents=True, exist_ok=True)

            s_samples = pl.DataFrame({'1': s_dosage.columns, '2': s_dosage.columns})

            s_samples.write_csv(f'{sdata_dir}/split{s}/split{s}_samples.txt', separator='\t', has_header=False)

        
        s_dosage = pl.concat((chr_var_list[c - 1], s_dosage), how='horizontal')
        
        s_dosage.write_csv(f'{sdata_dir}/split{s}/chr{c}_split{s}_dosage.txt', separator='\t', has_header=False)

        
        pigz.compress_file(f'{sdata_dir}/split{s}/chr{c}_split{s}_dosage.txt')

        Path(f'{sdata_dir}/split{s}/chr{c}_split{s}_dosage.txt').unlink(missing_ok=True)
        
        
        print(f'split {s}, chr {c} done @ {datetime.now().strftime("%d/%m/%y %H:%M:%S")}')
        