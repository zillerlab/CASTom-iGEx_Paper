# Source: Software/model_training/preProcessing_data_run.R

import polars as pl
from pybiomart import Dataset


epixcan_data_dir = '/scratch/tmp/dolgalev/castom-igex-revision/epixcan/data'


genes_annot = (
    Dataset(name='hsapiens_gene_ensembl', host='grch37.ensembl.org')
    .query(
        attributes=[
            'chromosome_name', 
            'start_position', 
            'end_position', 
            'strand', 
            'ensembl_gene_id', 
            'external_gene_name'
        ], 
        use_attr_names=True
    )
    .pipe(pl.DataFrame)
    .rename({'chromosome_name': 'chrom'})
    .filter(pl.col('chrom').str.n_chars() < 3)
    .with_columns(
        chrom='chr' + pl.col('chrom'), 
        TSS_start=pl.when(pl.col('strand') == 1).then(pl.col('start_position')).otherwise(pl.col('end_position') - 1), 
        TSS_end=pl.when(pl.col('strand') == 1).then(pl.col('start_position') + 1).otherwise(pl.col('end_position')),
        test_dev_geno=0.01,
        dev_geno=0.01
    )
    .unique(['chrom', 'TSS_start'], keep='first', maintain_order=True)
    .with_columns(name=pl.int_range(1, pl.col('ensembl_gene_id').count() + 1))
    .drop('strand')
    .select(
        pl.col(['chrom', 'TSS_start', 'TSS_end', 'name']), 
        pl.all().exclude(['chrom', 'TSS_start', 'TSS_end', 'name'])
    )
)


genes_annot.write_csv(f'{epixcan_data_dir}/biomart_grch37_gene_info.csv')
