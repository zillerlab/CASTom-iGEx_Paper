### functions ###
plot_summary_pathSEA <- function(cl_res, pathSEA){
    
    P <- length(unique(cl_res$cl_best$gr))
    gr_color <- pal_d3(palette = 'category20')(P)

    pathSEA_plot <- pathSEA
    pathSEA_plot$comp <- factor(paste0("gr", pathSEA_plot$gr))
    pathSEA_plot$atc_plot <- paste0(pathSEA_plot$atc_meaning1, " (", substr(pathSEA_plot$atc_code,1, 1), ")")
    pathSEA_plot$atc_1 <- substr(pathSEA_plot$atc_code,1, 1)
    pathSEA_plot <- pathSEA_plot %>% 
        group_by(comp) %>%
        arrange(atc_1, ES)
    pathSEA_plot <- pathSEA_plot %>% drop_na(atc_code)
    tmp <- pathSEA_plot[!duplicated(pathSEA_plot$atc_1),] %>%
        arrange(atc_1)

    pathSEA_plot$atc_plot <- factor(pathSEA_plot$atc_plot, tmp$atc_plot)
    gr_color <- gr_color[sort(unique(cl_res$cl_best$gr)) %in% pathSEA_plot$gr]

    pl1 <- ggplot(pathSEA_plot, mapping = aes(x = ES, y = atc_plot, 
                                          group = comp, color = comp, 
                                          size = -log10(PV))) + 
        geom_point(position = position_dodge(width = 0.7), alpha = 0.7) + 
        #facet_wrap(.~ comp, nrow = 1) + 
        geom_vline(xintercept = 0, linetype = "dashed", color = "black") + 
        scale_color_manual(values = gr_color) + 
        theme_bw() + 
        theme(legend.position = "bottom", axis.title.y = element_blank())

    pl2 <- ggplot(pathSEA_plot, mapping = aes(x = atc_plot, fill = comp)) + 
        geom_bar(stat = "count", color = "black", width = 0.6, size = 0.4) + 
        #facet_wrap(.~ comp, nrow = 1) + 
        theme_bw() + 
        theme(legend.position = "bottom", 
          axis.title.y = element_blank(), 
          axis.text.y = element_blank()) + 
        scale_fill_manual(values = gr_color) + 
        coord_flip()

    pl <- ggarrange(plotlist = list(pl1, pl2), 
                nrow = 1, common.legend = T, 
                widths = c(1, 0.3))


    return(pl)
    
}

standardize_pathway_names <- function(db_name, res_pval) {
    
    pathway_names <- do.call(rbind, res_pval) %>% filter(name == db_name)
    pathway_names <- pathway_names$path 
    pathway_names <- pathway_names[!duplicated(pathway_names)]

    df_names <- data.frame(original = pathway_names)
    # filter
    new_names <- pathway_names %>% toupper() %>% 
      str_replace_all(pattern =  "-",  replacement = "_") %>%
      str_replace_all(pattern =  "/",  replacement = "_") %>%
      str_replace_all(pattern =  " ",  replacement = "_") %>% 
      str_replace_all(pattern =  "[(]",  replacement = "") %>% 
      str_replace_all(pattern =  "[)]",  replacement = "") %>% 
      str_replace_all(pattern =  "___",  replacement = "_")
    new_names <- str_c(toupper(db_name), "_", new_names)
    df_names$updated <- new_names
    
    return(df_names)
}

get_group_specific_path <- function(path_feat, FDR_thr) {

     # load results:
    tot_res <- do.call(rbind, path_feat$test_feat) %>% filter(pval_corr <= FDR_thr)
    gr <- sort(unique(tot_res$comp))
    n_gr <- length(gr)

    gr_res <- lapply(1:n_gr, function(x) tot_res[tot_res$comp == sprintf('gr%i_vs_all', x),])
    # remove discordant results in sign
    for(i in 1:n_gr){
      tmp <- gr_res[[i]]
      dup_path <- names(which(table(tmp$feat) > 1))
      if(length(dup_path)>0){
        rm_path <- c()
        for(j in 1:length(dup_path)){
          tmp_path <- tmp %>% filter(feat == dup_path[j])
          if(!(all(tmp_path$estimates > 0) | all(tmp_path$estimates < 0))){
            rm_path <- c(rm_path, dup_path[j])
          }
        }
        gr_res[[i]] <- gr_res[[i]][!gr_res[[i]]$feat %in% rm_path,]
      }
    }

    return(gr_res)
}

get_drug_pathway_df <- function(pathSEA, gr_id, 
                                    atc_meaning1 = NULL, 
                                    keep_na = FALSE) {
    
    tmp <- pathSEA[order(abs(pathSEA$ES), decreasing = T),]
    tmp <- tmp[tmp$gr == gr_id,]
    if(!keep_na) {
        tmp <- tmp[!(is.na(tmp$atc_meaning1)),]
    }
    if(!is.null(atc_meaning1)) {
        tmp <- tmp[tmp$atc_meaning1 %in% atc_meaning1,]
    }    
    df_combined <- list()
    
    if(nrow(tmp)>1){
    for(i in 1:nrow(tmp)){
    
        drug_name <- tmp$drug[i]
        gr_name <- tmp$gr[i]
        PV <- tmp$PV[i]
        ES <- tmp$ES[i]
        type_path <- tmp$type[i]
        db_path <- tmp$db[i]
        atc <- tmp$atc_code[i]
    
        coll_name <- df_collname$v1[df_collname$v2 == db_path]
        peps <- gep2pep:::.loadPEPs(rp = rpBig, coll = coll_name)
    
        if (db_path == "Reactome") {
            df_names <- df_names_R
        } else {
            df_names <- df_names_GO
        }
            
        if (type_path == "up-reg pathways") {
            df_tmp <- df_names[df_names$original %in% gr_res[[gr_name]]$feat[gr_res[[gr_name]]$estimates > 0],]
        }else{
            df_tmp <- df_names[df_names$original %in% gr_res[[gr_name]]$feat[gr_res[[gr_name]]$estimates < 0],]
        }
    
        if(db_path == "Reactome"){collection = Reactome_coll}
        if(db_path == "GO_MF"){collection = GO_MF_coll}
        if(db_path == "GO_BP"){collection = GO_BP_coll}
        if(db_path == "GO_CC"){collection = GO_CC_coll}
    
        id <- which(sapply(collection, function(x) x@setName) %in% df_tmp$updated)
        db_filt <- collection[id]
    
        pathways <- gep2pep:::convertFromGSetClass(db_filt)
        pathway_ids <- names(pathways)
        pathway_names <- sapply(pathways, function(x) x$name)
   
        df_tmp <- df_names[match(pathway_names, df_names$updated),]
        gr_test <- gr_res[[gr_name]][match(df_tmp$original, gr_res[[gr_name]]$feat),]

        df_combined[[i]] <- data.frame(
            feat = gr_test$feat,
            name_complete = paste0(gr_test$feat, " (", db_path, ")"), 
            tissue = gr_test$tissue, 
            wmw_est = gr_test$estimates, 
            path_ES = peps$ES[pathway_ids, drug_name], 
            path_PV = peps$PV[pathway_ids, drug_name], 
            drug = drug_name,
            atc = atc, 
            PV = PV, 
            ES = ES,
            db = db_path)

    }

    df_combined <- do.call(rbind, df_combined)
    }
    return(df_combined)
    
}
                                
get_color_atc <- function(atc_codes){
    
    n <- length(atc_codes)
    h1 <- hcl.colors(n, palette = "Dynamic")
    df <- data.frame(name = atc_codes, col = h1)
    return(df)
}
                                
                                
### functions ###
get_drug_pathway_matrix <- function(df) { 

    # create matrices 
    db_types <- unique(df$db)

    mat_db <- list()
    for(i in 1:length(db_types)){
        
        tmp <- df[df$db == db_types[i], ]
        drug_names <- unique(tmp$drug)
        feat_names <- unique(tmp$feat)
        mat_db[[i]] <- matrix(nrow = length(feat_names), ncol = length(drug_names))
        rownames(mat_db[[i]]) <- feat_names
        colnames(mat_db[[i]]) <- drug_names
        for(j in 1:length(drug_names)) {
            val <- sign(tmp$path_ES[tmp$drug == drug_names[j]]) * (-log10(tmp$path_PV[tmp$drug == drug_names[j]]))
            id <- match(tmp$feat, feat_names)
            mat_db[[i]][id,j] <- val
        }
    } 
    
    return(mat_db)
}

plot_drug_pathway <- function(gr_id, db_id, dp_gr, 
                              pathSEA, gr_res, atc_color, 
                              width_plot, 
                              height_plot, 
                              outFold) {
    
    db_name <- unique(dp_gr[[gr_id]]$db)[[db_id]]
    mat_tmp <- get_drug_pathway_matrix(df = dp_gr[[gr_id]])[[db_id]]
    gr_tmp <- pathSEA %>% filter(gr == gr_id, db == db_name, drug %in% colnames(mat_tmp))

    if(min(mat_tmp)>0){
        val_col_fun <- colorRamp2(
            c(0, max(mat_tmp)), 
            c("#F0F0F0", "red"))    
    } else {
       if(max(mat_tmp) < 0) {
            val_col_fun <- colorRamp2(
            c(min(mat_tmp),  0), 
            c("blue", "#F0F0F0"))    
        } else {
            max_abs_val <- max(abs(mat_tmp))
            val_col_fun <- colorRamp2(
            c(-max_abs_val, 0, max_abs_val), 
            c("blue", "#F0F0F0", "red"))   
       }
    }


    colors_gr <- pal_d3(palette = 'category20')(length(dp_gr))[gr_id]
    lgd_est <- Legend(title = "signed -log10(P)", col = val_col_fun)
    
    id <- order(gr_tmp$atc_meaning1)
    n_atc1 <- length(unique(gr_tmp$atc_meaning1))
    gr_tmp <- gr_tmp[id, ]
    mat_tmp <- mat_tmp[, match(gr_tmp$drug, colnames(mat_tmp))]

    drug_atc <- list(atc1 = gr_tmp$atc_meaning1, atc3 = gr_tmp$atc_meaning3)
    tmp <- atc_color[atc_color$name %in% gr_tmp$atc_meaning1, ]
    atc_color_tmp <- tmp$col
    names(atc_color_tmp) <- tmp$name

    column_ha <- HeatmapAnnotation(
        atc1 = gr_tmp$atc_meaning1, 
        col = list(atc1 = atc_color_tmp), 
        signed_p = anno_barplot(gr_tmp$sign_p, height = unit(1.5, "cm")))

    dp_feat <- dp_gr[[gr_id]] %>% filter(db %in% db_name) %>% mutate(new_id = paste(feat, tissue, sep = "_"))
    feat_gr <- gr_res[[gr_id]] %>% mutate(new_id = paste(feat, tissue, sep = "_"))
    feat_gr <- feat_gr %>% filter(new_id %in% dp_feat$new_id)
    feat_gr <- feat_gr[match(rownames(mat_tmp),feat_gr$feat),]

    if(min(feat_gr$estimates)>0){
        WMWest_col_fun <- colorRamp2(
            c(0, max(feat_gr$estimates)), 
            c("#F0F0F0", "#BF443B"))    
    } else {
        WMWest_col_fun <- colorRamp2(
            c(min(feat_gr$estimates), 0), 
            c("#00677B", "#F0F0F0"))    
    }

    row_ha <- rowAnnotation(
        WMW_est = feat_gr$estimates, 
        col = list(WMW_est = WMWest_col_fun),
        annotation_name_gp = gpar(col = "transparent"))

    hm_pl <- Heatmap(mat_tmp, 
                 col = val_col_fun, show_heatmap_legend = FALSE, 
                 cluster_columns = FALSE,
                 column_names_rot = 45, 
                 column_split = gr_tmp$atc_meaning1, 
                 column_title = paste0("gr", gr_id, " (", db_name, ")"), 
                 column_title_gp = gpar(fill = colors_gr, col = "white", fontface = "bold", border = "black"), 
                 bottom_annotation = column_ha, 
                 heatmap_legend_param = list(nrow = 1),
                 show_row_dend = FALSE, 
                 left_annotation = row_ha)

    pdf(sprintf('%sheatmap_drug_pathway_gr%i_%s.pdf', outFold, gr_id, db_name), 
        #width = 8 + ncol(mat_tmp)*0.15, height = 3 + nrow(mat_tmp)*0.15)
        width = width_plot, height = height_plot)
    draw(hm_pl, annotation_legend_list = list(lgd_est))
    dev.off()
    
    draw(hm_pl, annotation_legend_list = list(lgd_est))
    
}

