# CASTom-iGEx application

Application of [CASTom-iGEx](https://gitlab.mpcdf.mpg.de/luciat/castom-igex.git) pipeline to coronary artery disease and schizophrenia. Analysis performed for publication xx.

In each folder, **run_command** text file explains the sequence of script used.  The subfolder order follow castom-igex workflow: training --> prediction --> clustering. 
- *PriLer*: analysis to assess and benchmark PriLer performances without the harmonization to any other dataset
- *CAD*: castom-igex application to CAD from UKBB and CARDIoGRAM cohorts. Additional folders refers to other validation analysis apart from **output_summary** that includes summary tables for the pipeline.
- *SCZ_PGC2*: castom-igex application to SCZ from PGC wave2. Folder structure similar to CAD. For the **clustering** scripts to be working, it is necessary to have run *UK_Biobank* scripts first. 
- *UK_Biobank*: UKBB training and prediction on GTEx and CMC necessary to compute gene risk-score for PGC cohorts and predict cluster dfferences.
