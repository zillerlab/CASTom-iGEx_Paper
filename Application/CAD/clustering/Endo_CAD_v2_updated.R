options(stringsAsFactors=F)
options(max.print=1000)
library(dplyr)
prefix="Integrated_analysis_v2"
#I. Get intersection of pathways associated with CAD, endopheno and different across groups per tissue and take union across tissues
#1. get pathways different between groups
setwd("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs")

load("pathOriginal_filtJS0.2_corrPCs_tscoreClusterCases_featAssociation.RData")
#This object also includes original pathway scores for the cases (output$inputData) and the scaled version 
#used for testing (output$scaleData) and the clustering results (output$cl) and the corresponding CAD PALAS results (output$res_pval)
#- A summary in tabular format is also here: 

pathway_feat=output
tot <- do.call(rbind, pathway_feat$test_feat)
tot %>% group_by(comp) %>% summarise(count = n())

path_tot_res <- tot %>% filter(pval_corr <= 0.01)
nrow(path_tot_res)
gr <- sort(unique(path_tot_res$comp))
n_gr <- length(gr)

path_gr_res <- lapply(1:n_gr, function(x) path_tot_res[path_tot_res$comp == sprintf('gr%i_vs_all', x),])
# remove discordant results in sign
for(i in 1:n_gr){
  tmp <- path_gr_res[[i]]
  dup_path <- names(which(table(tmp$feat) > 1))
  if(length(dup_path)>0){
    rm_path <- c()
    for(j in 1:length(dup_path)){
      tmp_path <- tmp %>% filter(feat == dup_path[j])
      if(!(all(tmp_path$estimates > 0) | all(tmp_path$estimates < 0))){
        rm_path <- c(rm_path, dup_path[j])
      }
    }
    path_gr_res[[i]] <- path_gr_res[[i]][!path_gr_res[[i]]$feat %in% rm_path,]
  }
}

path_gr_res <- do.call(rbind, path_gr_res)
nrow(path_gr_res)
path_gr_res %>% group_by(comp) %>% summarise(count = n())
length(unique(path_gr_res$feat))
a = path_gr_res %>% group_by(tissue) %>% summarise(count = length(unique(feat)))
sum(a$count)
#group pathways:
path_gr_res 
##################
setwd("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/filter_endopheno/")
#2. Endopheno pathways
tissues=unique(path_gr_res[,"tissue"])
dClass=list.files(paste0("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/",tissues[1],"/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/"))
dClass=dClass[grep("pval_",dClass)]
exclude=c("pval_CAD_pheno_covCorr_customPath_WikiPath2019Human.RData","pval_tscore.RData" ,"pval_CAD_pheno_covCorr_customPath_geneSets_sameLocus.RData")
reactomeRes=data.frame()
goRes=data.frame()
for (i in 1:length(tissues)){
  dClass=list.files(paste0("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/",tissues[i],"/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/"))
  dClass=dClass[grep("pval_",dClass)]
  dClass=dClass[!is.element(dClass,exclude)]
  medCor=dClass[grep("_withMed",dClass)]
  d=as.character(unlist(lapply(medCor,function(X){
    tmp=strsplit(X,"_withMed")[[1]][1]
    return(dClass[grep(tmp,dClass)])
  })))
  dClass=c(medCor,setdiff(dClass,d))
    for (j in 1:length(dClass)){
    load(paste0("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/",tissues[i],"/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/",dClass[j]))
    for (k in 1:length(final$pathScore_reactome)){
      cMat=cbind(pheno_id=final$pheno[k,"pheno_id"],phenoName=final$pheno[k,"Field"],tissue=tissues[i],final$pathScore_reactome[[k]])
      cMat=cMat[cMat[,grep("BHcorr",names(cMat))]<=0.05, ]
      if (nrow(cMat)>0){
        names(cMat)[c(13:18)]=c("beta","se_beta","z_t","pval","qval","BHcorr")
        reactomeRes=rbind(reactomeRes,cMat)
      }
      cMat=cbind(pheno_id=final$pheno[k,"pheno_id"],phenoName=final$pheno[k,"Field"],tissue=tissues[i],final$pathScore_GO[[k]])
      names(cMat)[c(15:20)]=c("beta","se_beta","z_t","pval","qval","BHcorr")
      cMat=cMat[cMat[,grep("BHcorr",names(cMat))]<=0.05, ]
      if (nrow(cMat)>0){
        goRes=rbind(goRes,cMat)
      }
    }
  }
  print(i)
}
save.image(paste(prefix,"dataLoading_completed.bin"))
#######
#filter and export
write.table(  goRes,paste(prefix,"All_pathways_AllTissues_endo_anlaysis_GO.txt",sep="_"),sep="\t",quote=F,row.names=F)
write.table(  reactomeRes,paste(prefix,"All_pathways_AllTissues_endo_anlaysis_Reactome.txt",sep="_"),sep="\t",quote=F,row.names=F)
goRes=goRes[goRes[,"ngenes_tscore"]>=3&goRes[,"ngenes_tscore"]<=200,]
reactomeRes=reactomeRes[reactomeRes[,"ngenes_tscore"]>=3&reactomeRes[,"ngenes_tscore"]<=200,]
write.table(  goRes,paste(prefix,"All_pathways_AllTissues_endo_anlaysis_GO_filt.txt",sep="_"),sep="\t",quote=F,row.names=F)
write.table(  reactomeRes,paste(prefix,"All_pathways_AllTissues_endo_anlaysis_Reactome_filt.txt",sep="_"),sep="\t",quote=F,row.names=F)
###################
#create indicator matrix for 1. CAD,all endos and gr diff AND 2. all endos and gr diff
uGo=unique(goRes[,"path"])
uReact=unique(reactomeRes[,"path"])
uEndo=as.character(unique(union(goRes[,"pheno_id"],reactomeRes[,"pheno_id"])))
iMat1GO=matrix(0,length(uGo),2+length(uEndo))
rownames(iMat1GO)=uGo
colnames(iMat1GO)=c("CAD","GroupDiff",uEndo)
iMat2GO=matrix(0,length(uGo),1+length(uEndo))
rownames(iMat2GO)=uGo
colnames(iMat2GO)=c("GroupDiff",uEndo)
iMat1React=matrix(0,length(uReact),2+length(uEndo))
rownames(iMat1React)=uReact
colnames(iMat1React)=c("CAD","GroupDiff",uEndo)
iMat2React=matrix(0,length(uGo),1+length(uEndo))#not needed, just ignore CAD
rownames(iMat2React)=uGo
colnames(iMat2React)=c("GroupDiff",uEndo)

for (i in 1:length(tissues)){
 #cDat1=merge(path_gr_res[path_gr_res[,"tissue"]==tissues[i],],goRes[goRes[,"tissue"]==tissues[i],c("pheno","path","qval","z_t")],by.x="feat",by.y="path",all.x=F,all.y=F)
#cDat1=cbind(cDat1,pClass="GO")
  iMat1GO[rownames(iMat1GO) %in%path_gr_res[path_gr_res[,"tissue"]==tissues[i],"feat"],"GroupDiff"]=1
  iMat1React[rownames(iMat1React) %in%path_gr_res[path_gr_res[,"tissue"]==tissues[i],"feat"],"GroupDiff"]=1
 # iMat2GO[rownames(iMat1GO %in%path_gr_res[path_gr_res[,"tissue"]==tissues[i],""]),"GroupDiff"]=1
#  iMat2React[rownames(iMat1React %in%path_gr_res[path_gr_res[,"tissue"]==tissues[i],""]),"GroupDiff"]=1
  
  for (j in 1:length(uEndo)){
    ind=goRes[,"tissue"]==tissues[i]&goRes[,"pheno_id"]==uEndo[j]
    ind[is.na(ind)]=F
   pNames=goRes[ind,"path"]
    if (length(pNames)>0){
    iMat1GO[pNames,uEndo[j]]=1
  #  if (uEndo[j]!="CAD"){
  #  iMat2GO[pNames,uEndo[j]]=1
  #  }
    }
   ind=reactomeRes[,"tissue"]==tissues[i]&reactomeRes[,"pheno_id"]==uEndo[j]
   ind[is.na(ind)]=F
   pNames=reactomeRes[ind,"path"]
   if (length(pNames)>0){
     iMat1React[pNames,uEndo[j]]=1
   #  if (uEndo[j]!="CAD"){
  #     iMat2React[pNames,uEndo[j]]=1
  #   }
   }
  }
}
library(data.table)
setwd('/psycl/g/mpsziller/lucia/')
fold <- 'CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/AllTissues/200kb/CAD_GWAS_bin5e-2/UKBB/'
fold_rep <- 'CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/AllTissues/200kb/CAD_GWAS_bin5e-2/Meta_Analysis_CAD/'
pheno <- 'CAD_HARD'
pathR <- fread(sprintf('%spath_Reactome_pval_%s_covCorr_filt.txt', fold, pheno), 
               h=T, stringsAsFactors = F, sep = '\t', data.table = F)

pathGO <- fread(sprintf('%spath_GO_pval_%s_covCorr_filt.txt', fold, pheno), 
                h=T, stringsAsFactors = F, sep = '\t', data.table = F)

iMat1GO[,"CAD_HARD"]=0
iMat1React[,"CAD_HARD"]=0
namGo=unique(pathGO[pathGO[,"CAD_HARD_BHcorr"]<=0.05,2])
namGo=intersect(namGo,rownames(iMat1GO))
iMat1GO[namGo,"CAD_HARD"]=1

namR=unique(pathR[pathR[,"CAD_HARD_BHcorr"]<=0.05,1])
namR=intersect(namR,rownames(iMat1React))
iMat1React[namR,"CAD_HARD"]=1


#get list of detected Endos
endoGO1=colnames(iMat1GO)[colSums((iMat1GO[,"GroupDiff"]==1&iMat1GO[,"CAD_HARD"]==1)&iMat1GO==1)!=0]
endoReact1=colnames(iMat1React)[colSums((iMat1React[,"GroupDiff"]==1&iMat1React[,"CAD_HARD"]==1)&iMat1React==1)!=0]
endoGO2=colnames(iMat1GO)[colSums((iMat1GO[,"GroupDiff"]==1)&iMat1GO==1)!=0]
endoReact2=colnames(iMat1React)[colSums((iMat1React[,"GroupDiff"]==1)&iMat1React==1)!=0]
######
allEndos1=unique(union(endoGO1,endoReact1))
allEndos2=union(endoGO2,endoReact2)
#get groupwise associated endos
setwd('/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT')
fold_cl <- "OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/"
cl_endophenotype <- read.delim(sprintf('%stscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM_combined.txt', fold_cl), h=T, stringsAsFactors = F)
pheno_res <- get(load('OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/rescaleCont_withMedication_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData'))
pheno_res_nomed <- get(load('OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/rescaleCont_withoutMedication_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData'))
#medIds=union(pheno_res_nomed[[2]][grep("Medication",pheno_res_nomed[[2]][,3]),1],pheno_res_nomed[[2]][grep("medication",pheno_res_nomed[[2]][,3]),1])
#allEndos1=allEndos1[!is.element(allEndos1,medIds)]
cl_endophenotype=cl_endophenotype[cl_endophenotype[,"pheno_id"] %in%allEndos1,]
uGroups=unique(cl_endophenotype[,"comp"])

pheno_plot <- c('Hyperlipidemia', 'Coronary_artery_bypass_graft', 'Age_stroke', 'Chronic_obstructive_pulmonary_disease', 'Peripheral_vascular_disease')
data_endophenotype_HD <- get(load(sprintf('%snominalAnalysis_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.RData', fold_cl)))
diagDat<- data_endophenotype_HD$bin_reg
phenoDat <- data_endophenotype_HD$phenoDat

for (i in 1:length(uGroups)){
  ind=cl_endophenotype[,"comp"]==uGroups[i]
  cl_endophenotype[ind,"pval_corr"]=p.adjust(cl_endophenotype[ind,"pvalue"],method="BH")
}
#extract results for spider plots
#filter table for these endopheno and filter pathway indicator table for identified endopheno
ind=cl_endophenotype[,"pval_corr"]<=0.05
ind[is.na(ind)]=F
cl_endophenotype[ind,2]
endoSig=cl_endophenotype[ind,]
setwd("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/filter_endopheno/")
write.table(endoSig,paste(prefix,"Filtered_groupwise_endophenotypes_v2.txt",sep="_"),sep="\t",quote=F,row.names=F)
write.table(cl_endophenotype,paste(prefix,"all_groupwise_endophenotypes_v2.txt",sep="_"),sep="\t",quote=F,row.names=F)

##### # controls
cl_endophenotype_controls <- read.delim(sprintf('%stscore_corrPCs_zscaled_clusterControls_PGmethod_HKmetric_phenoAssociation_GLM_combined.txt', fold_cl), h=T, stringsAsFactors = F)
cl_endophenotype_controls=cl_endophenotype_controls[cl_endophenotype_controls[,"pheno_id"] %in%allEndos1,]
uGroups=unique(cl_endophenotype_controls[,"comp"])

for (i in 1:length(uGroups)){
  ind=cl_endophenotype_controls[,"comp"]==uGroups[i]
  cl_endophenotype_controls[ind,"pval_corr"]=p.adjust(cl_endophenotype_controls[ind,"pvalue"],method="BH")
}
#extract results for spider plots
#filter table for these endopheno and filter pathway indicator table for identified endopheno
ind=cl_endophenotype_controls[,"pval_corr"]<=0.05
ind[is.na(ind)]=F
cl_endophenotype_controls[ind,2]
endoSig_controls=cl_endophenotype_controls[ind,]
setwd("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/filter_endopheno/")
write.table(endoSig_controls,paste(prefix,"Filtered_groupwise_endophenotypes_controls_v2.txt",sep="_"),sep="\t",quote=F,row.names=F)
write.table(cl_endophenotype_controls,paste(prefix,"all_groupwise_endophenotypes_controls_v2.txt",sep="_"),sep="\t",quote=F,row.names=F)
#####

##### controls original
cl_endophenotype_controls_original <- read.delim(sprintf('%stscore_corrPCs_original_clusterControls_PGmethod_HKmetric_phenoAssociation_GLM_combined.txt', fold_cl), h=T, stringsAsFactors = F)
cl_endophenotype_controls_original=cl_endophenotype_controls_original[cl_endophenotype_controls_original[,"pheno_id"] %in%allEndos1,]
uGroups=unique(cl_endophenotype_controls_original[,"comp"])

for (i in 1:length(uGroups)){
  ind=cl_endophenotype_controls_original[,"comp"]==uGroups[i]
  cl_endophenotype_controls_original[ind,"pval_corr"]=p.adjust(cl_endophenotype_controls_original[ind,"pvalue"],method="BH")
}
#extract results for spider plots
#filter table for these endopheno and filter pathway indicator table for identified endopheno
ind=cl_endophenotype_controls_original[,"pval_corr"]<=0.05
ind[is.na(ind)]=F
cl_endophenotype_controls_original[ind,2]
endoSig_controls_original=cl_endophenotype_controls_original[ind,]
setwd("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/filter_endopheno/")
write.table(endoSig_controls_original,paste(prefix,"Filtered_groupwise_endophenotypes_controls_original_v2.txt",sep="_"),sep="\t",quote=F,row.names=F)
write.table(cl_endophenotype_controls_original,paste(prefix,"all_groupwise_endophenotypes_controls_original_v2.txt",sep="_"),sep="\t",quote=F,row.names=F)
#####

uCmps=unique(endoSig[,"comp"])
uEndo=endoSig[,"pheno_id"]
fGo=iMat1GO[,uEndo]
fReact=iMat1React[,uEndo]
fGo=fGo[rowSums(fGo)>0,]
fReact=fReact[rowSums(fReact)>0,]
for (i in 1:length(uCmps)){
 cDat=path_gr_res[ path_gr_res[,"comp"]==uCmps[i]&path_gr_res[,"pval_corr"]<=0.05,]
 #filter for those associated with relevant endophenos from this comparison
 cEndo=endoSig[endoSig[,"comp"]==uCmps[i],"pheno_id"]
 fNames=unique(union(rownames(fGo)[rowSums(fGo[,cEndo])>0],rownames(fReact)[rowSums(fReact[,cEndo])>0]))
 cDat=cDat[cDat[,"feat"]%in%fNames,]
  #reduce to lowest pval
 uFeats= unique(cDat[,1])
 cDat=lapply(uFeats,function(X){
   tmp=cDat[cDat[,1]==X,,drop=F]
   return(tmp[which.min(tmp[,"pval_corr"]),])
 })
 cDat=do.call(rbind,cDat)
 if (i==1){
   pgr_res=cDat
 }else{
   pgr_res=rbind(pgr_res,cDat)
 }
}
write.table(pgr_res,paste(prefix,"_final_groupwise_pathways_collapsed_005_v2.txt",sep="_"),sep="\t",quote=F,row.names=F)
#diagDat=diagDat[diagDat[,"pvalue"]<=0.05,]
diagDat=diagDat[diagDat$pheno_id %in%pheno_plot ,]
write.table(diagDat,paste(prefix,"_final_groupwise_diagnosis_nominalPlot_v2.txt",sep="_"),sep="\t",quote=F,row.names=F)
save.image(paste(prefix,"completed.bin",sep="_"))


#######################
##################
options(stringsAsFactors=F)
options(max.print=1000)
library(dplyr)
prefix="Integrated_analysis_v2"
#Compute empirical p-value for individual endophenotypes based on random clustering 
setwd("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/random_cluster/")
#Each repetition is indicating at the beginning (rep1_)
#For example, the results for the hypothesis-driven endophenotype are in this format:
#  rep1_nominalAnalysis_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt
#(repeated 50 times).
tab=read.table("rep1_nominalAnalysis_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt",sep="\t",header=T)
uGroups=unique(tab[, "comp"])
uPheno=unique(tab[,1])
pMat=matrix(1,50,5*length(uPheno))
pMat=array(1,c(50,length(uPheno),length(uGroups)))
for (i in 1:50){
  tab=read.table(paste0("rep",i,"_nominalAnalysis_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt"),sep="\t",header=T)
  pMat[i,,]=t(sapply(uPheno,function(X){
    r=tab[tab[,1]==X,"pvalue"]
    return(r)
  }))
}

empP=sapply(seq(1,length(uPheno)),function(X){
  n=length(pMat[,X,])
  return(sum(pMat[,X,]<=0.01)/n)
})
names(empP)=uPheno


ref=read.table("/psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/nominalAnalysis_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt",sep="\t",header=T)
#Instead, the actual hypothesis-driven analysis is here:
#  /psycl/g/mpsziller/lucia/CAD_UKBB/eQTL_PROJECT/OUTPUT_GTEx/predict_CAD/Liver/200kb/CAD_GWAS_bin5e-2/UKBB/devgeno0.01_testdevgeno0/CAD_HARD_clustering/update_corrPCs/
#  nominalAnalysis_tscore_corrPCs_zscaled_clusterCases_PGmethod_HKmetric_phenoAssociation_GLM.txt
sNam=ref[ref[,"pvalue"]<=0.01,1]
empP[sNam]

