### This function plots a scatterplot on a football field and is designed to
### work nicely with the data provided in the NFL Big Data Bowl 2021


library(tidyverse)

ggfootball <- function(gplot) {
  
  # Create data frames to add lines to field, hash marks, and 10-yard labels
  five_yard_df <- data.frame(x = seq(from = 15, to = 105, by = 5))
  hash_df <- data.frame(x = 11:109)
  yard_labels_df <- data.frame(x = seq(from = 20, to = 100, by = 10),
                               y = rep(x = 4, n = 9),
                               digits = c(seq(from = 10, to = 50, by = 10),
                                          seq(from = 40, to = 10, by = -10)))
  
  # Make middle of field green
  gplot + geom_rect(data = NULL, 
                    aes(xmin = 10, xmax = 110, ymin = 0, ymax = 53.3), 
                    fill = "green4", color = "black", alpha = 0.1) +
    
    # Add endzones
    geom_rect(data = NULL, 
              aes(xmin = 0, xmax = 10, ymin = 0, ymax = 53.3), 
              fill = "darkslategray", color = "black", alpha = 0.1) +
    geom_rect(data = NULL, 
              aes(xmin = 110, xmax = 120, ymin = 0, ymax = 53.3), 
              fill = "darkslategray", color = "black", alpha = 0.1) +
    
    # Format gridlines, tick marks, tick labels, and border of plot window
    theme_bw() +
    theme(panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          panel.border = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          axis.title = element_blank(),
          text = element_text(size = 16),
          #, legend.position = "none" # Optional hiding of legend
    ) +
    
    # Add vertical lines at each 5-yard increment
    geom_segment(data = five_yard_df,
                 mapping = aes(x = x, xend = x, y = -Inf, yend = 53.3),
                 color = "white") +
    
    # Add hash marks to field
    geom_segment(data = hash_df,
                 mapping = aes(x = x, xend = x, y = 0.5, yend = 1.5),
                 color = "white") +
    geom_segment(data = hash_df,
                 mapping = aes(x = x, xend = x, y = 51.8, yend = 52.8),
                 color = "white") +
    #  geom_segment(data = hash_df,
    #               mapping = aes(x = x, xend = x, y = 17.8, yend = 18.8),
    #               color = "white") +
    #  geom_segment(data = hash_df,
    #               mapping = aes(x = x, xend = x, y = 34.6, yend = 35.6),
    #               color = "white") +
    
    # Add yard line labels to field
    geom_text(data = yard_labels_df, 
              mapping = aes(x = x, y = y, label = digits),
              color = "white", size = 6) +
    geom_text(data = yard_labels_df, 
              mapping = aes(x = x, y = 53.3 - y, label = digits),
              color = "white", angle = 180, size = 6) +
    
    # Create a final solid black outline for the field
    geom_rect(data = NULL, 
              aes(xmin = 10, xmax = 110, ymin = 0, ymax = 53.3), 
              fill = NA, color = "black") +
    
    # Add points and change colors of points in scatterplot
#    geom_point(size = 4) +
#    scale_color_manual(values = c("black", "slategray1", "red")) +
    
    # Label legend
    labs(color = "Legend") +
    
    # Add x and y axis limits
    lims(x = c(0, 120), y = c(-1, 59))
}
