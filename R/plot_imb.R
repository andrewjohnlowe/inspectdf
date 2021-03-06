plot_imb_1 <- function(df_plot, df_names){
  # convert col_name to factor
  df_plot <- df_plot %>% 
    mutate(col_name = factor(col_name, levels = as.character(col_name))) %>%
    mutate(label = paste0(value, " - ", round(pcnt, 1), "%"))
  # title & subtitle
  ttl <- paste0("df::", df_names$df1, " most common levels by column")
  # construct bar plot of missingess
  plt <- bar_plot(df_plot = df_plot, x = "col_name", 
                  y = "pcnt", fill = "col_name", 
                  label = "label", ttl = ttl,
                  ylb = "% of values", rotate = TRUE)
  # add text annotation to plot
  plt <- add_annotation_to_bars(x = df_plot$col_name, 
                                y = df_plot$pcnt, 
                                z = df_plot$value, 
                                plt = plt, 
                                thresh = 0.5)
  # return plot
  print(plt)
}

plot_imb_2 <- function(df_plot, df_names, alpha){
  
  # combine col_name and value
  df_plot <- df_plot %>% 
    mutate(col_name = paste0(col_name, "\n(", value, ")"))
  # save a version of plotting data for later
  na_tab  <- df_plot
  # convert to tall
  df_plot <- df_plot %>% 
    select(-starts_with("cnt")) %>% 
    gather(key = "data_frame", value = "pcnt", -col_name, -p_value, -value) %>%
    mutate(data_frame = as.integer(gsub("pcnt_", "", data_frame))) %>%
    mutate(col_name = factor(col_name, levels = as.character(na_tab$col_name))) %>%
    mutate(data_frame = unlist(df_names)[data_frame])
  # reverse row order of plotting data
  df_plot <- df_plot[nrow(df_plot):1, ]
  # calculate significance 
  p_val_tab <- df_plot %>% 
    mutate(is_sig = as.integer(p_value < alpha) + 2, index = 1:nrow(df_plot)) %>%
    replace_na(list(is_sig = 1)) %>%
    select(is_sig, index) 
  
  # generate plot
  plt <- df_plot %>%
    ggplot(aes(x = col_name, 
               y = pcnt, 
               colour = data_frame)) +
    geom_blank() + theme_bw() + 
    theme(panel.border = element_blank(), 
          panel.grid.major = element_blank()) +
    geom_rect(
      fill = c("grey85", "darkorange2", "royalblue1")[p_val_tab$is_sig], alpha = 0.2,
      xmin = p_val_tab$index - 0.4, xmax = p_val_tab$index + 0.4,
      ymin = -100, ymax = 200, linetype = "blank") +
    geom_hline(yintercept = 0, linetype = "dashed", color = "lightsteelblue4") + 
    geom_point(size = 3.7, color = "black", na.rm = TRUE) + 
    geom_point(size = 3, na.rm = TRUE) +
    coord_flip()
  
  # title & subtitle
  ttl <- paste0("Comparison of most common levels")
  sttl <- paste0("Blue and orange stripes are equality or", 
                 " inequality at ", bquote("\u03B1"), " = 0.05")
  plt <- plt + 
    labs(x = "", title = ttl, subtitle = sttl) + 
    guides(colour = guide_legend(title = bquote("Data frame"))) + 
    labs(y = "% of values", x = "") %>% 
    suppressWarnings()
  
  # return the plot 
  print(plt)
}