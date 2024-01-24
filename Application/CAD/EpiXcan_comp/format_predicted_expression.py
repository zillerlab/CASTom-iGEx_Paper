import sqlite3
from datetime import datetime
from pathlib import Path

import pigz_python as pigz
import polars as pl


epixcan_model_dir = '/cloud/wwu1/h_fungenpsy/AGZiller_data/EpiXcan/PredictDB'
epixcan_dir = '/scratch/tmp/dolgalev/castom-igex-revision/epixcan'


egldb = sqlite3.connect(f'{epixcan_model_dir}/GTEx_Liv_EpiX_alpha0.5_window1e6_filtered.db').cursor()

genes_perf = (
    pl.DataFrame(
        egldb.execute('SELECT gene, "pred.perf.qval" FROM extra'), 
        schema=['ensembl_gene_id', 'pred_perf_qval']
    )
    .filter(pl.col('pred_perf_qval') <= 0.01)
    .get_column('ensembl_gene_id')
)

genes_annot = (
    pl.read_csv(f'{epixcan_dir}/data/biomart_grch37_gene_info.csv')
    .filter(pl.col('ensembl_gene_id').is_in(genes_perf))
)


split = range(1, 101)


pred_exp = list()

for s in split:
    pred_exp_file = f'{epixcan_dir}/results/predexp/split{s}_predicted_expression'

    pred_exp_s = (
        pl.read_csv(f'{pred_exp_file}.txt.gz', separator='\t')
        .select(pl.col(genes_annot.get_column('ensembl_gene_id')))
    )

    pred_exp.append(pred_exp_s)


pred_exp = pl.concat(pred_exp)


genes_zero = [col.name for col in pred_exp.select(pl.all() == 0.0) if col.all()]

genes_annot = genes_annot.filter(~pl.col('ensembl_gene_id').is_in(genes_zero))


for s in split:
    pred_exp_file = f'{epixcan_dir}/results/predexp/split{s}_predicted_expression'

    pred_exp_s = (
        pl.read_csv(f'{pred_exp_file}.txt.gz', separator='\t')
        .select(pl.col('IID'), pl.col(genes_annot.get_column('ensembl_gene_id')))
        .with_columns(IID='X' + pl.col('IID').cast(str))
        .transpose(column_names='IID')
    )

    pred_exp_s = pl.concat([genes_annot, pred_exp_s], how='horizontal')

    pred_exp_s.write_csv(f'{pred_exp_file}_fmt.txt', separator='\t')


    pigz.compress_file(f'{pred_exp_file}_fmt.txt')

    Path(f'{pred_exp_file}_fmt.txt').unlink(missing_ok=True)


    print(f'split {s} done @ {datetime.now().strftime("%d/%m/%y %H:%M:%S")}')
    