# CASTom-iGEx application

Application of [CASTom-iGEx](https://gitlab.mpcdf.mpg.de/luciat/castom-igex.git) pipeline to coronary artery disease and schizophrenia. Analysis performed for [Distinct genetic liability profiles define clinically relevant patient strata across common diseases.  Trastulla L., et al. MedRxiv, 2023](https://www.medrxiv.org/content/10.1101/2023.05.10.23289788v1).

### Application:
In each folder, **run_command** text file explains the sequence of script used.  The subfolder order follow castom-igex workflow: training --> prediction --> clustering. 
- *PriLer*: preprocessing of reference panels and analysis to assess and benchmark PriLer performances without the harmonization to any other dataset
- *UK_Biobank*: UKBB training and prediction on GTEx and CMC necessary to compute gene risk-score for PGC cohorts and predict cluster dfferences. Here the workflow is preproc_genotype --> training --> prediction.
- *CAD*: castom-igex application to CAD from UKBB and CARDIoGRAM cohorts. Additional folders refers to other validation analysis apart from **output_summary** that includes summary tables for the pipeline. Note that it is necessary to run scripts in UK_Biobank/preproc_genotype/ first to prepare the correct format for the genotype data.
- *SCZ_PGC2*: castom-igex application to SCZ from PGC wave2. Folder structure similar to CAD. For the **clustering** scripts to be working, it is necessary to have run *UK_Biobank* scripts first. 

### R:
Additional scripts necessary to summarise results

### jupyter_notebook:
- Notebooks containung figure panels for the publication. Sub-folders are divided by thematics.
