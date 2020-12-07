library(vroom)
library(tidyverse)

if (!exists("track_data")){
  track_data <- vroom("data/merged_data.csv.gz")
}

route_wanted <- c("GO","CROSS","SCREEN","OUT","POST")

# function to filter data
# this function will choose play that **all** WR's route is in `route_wanted` or
# play that **exists** WR's route is in `route_wanted`, and the result of play 
# greater than `yard_benchmark`
filter_for_eda <- function(route_wanted, all_WR = TRUE, yard_benchmark, max_plays = 100) {
  
  # identify plays that contains route we want
  included_play_id <- track_data %>%
    dplyr::select(playId, gameId, route) %>%
    filter(route %in% route_wanted) %>%
    dplyr::select(-route) %>%
    unique()
  
  # identify plays that contains route we don't want
  route_unwanted <- track_data %>%
    dplyr::select(route) %>%
    unique() %>%
    drop_na() %>%
    filter(!route %in% route_wanted) %>%
    pull()
  
  excluded_play_id <- track_data %>%
    dplyr::select(playId, gameId, route) %>%
    filter(route %in% route_unwanted) %>%
    dplyr::select(-route) %>%
    unique() %>%
    mutate(if_drop = TRUE)
  
  if (all_WR){
    filtered_play <- track_data %>%
      # first select the plays contains route we wanted, and then drop selected
      # plays that contains route we don't want
      inner_join(included_play_id, by = c("playId", "gameId")) %>%
      left_join(excluded_play_id, by = c("playId", "gameId")) %>%
      filter(is.na(if_drop)) %>%
      select(-if_drop)  %>%
      # filter complete pass
      filter(passResult == "C") %>%
      # filter offense play result that is bigger than benchmark
      filter(offensePlayResult > yard_benchmark)
  } else {
    filtered_play <- track_data %>%
      # select the plays contains route we wanted
      inner_join(included_play_id, by = c("playId", "gameId")) %>%
      # filter complete pass
      filter(passResult == "C") %>%
      # filter offense play result that is bigger than benchmark
      filter(offensePlayResult > yard_benchmark)
  }
  
  # random sample the play if there are too many play after filtering
  num_plays <- filtered_play %>% 
    dplyr::select(playId, gameId) %>%
    unique() %>%
    nrow()
  if (num_plays > max_plays) {
    set.seed(1)
    sample_id <- sample(num_plays, max_plays)
    random_play_id <- filtered_play %>% 
      dplyr::select(playId, gameId) %>%
      unique() %>%
      .[sample_id,]
    filtered_play <- filtered_play %>%
      inner_join(random_play_id, by = c("playId", "gameId"))
  }
  
  return(filtered_play)
}

# I made a little modification to ggfootball, so that it can plot with 
# aes(..., alpha = frameId)
ggfootball_for_eda <- function(df, aes) {
  
  # Create data frames to add lines to field, hash marks, and 10-yard labels
  five_yard_df <- data.frame(x = seq(from = 15, to = 105, by = 5))
  hash_df <- data.frame(x = 11:109)
  yard_labels_df <- data.frame(
    x = seq(from = 20, to = 100, by = 10),
    y = rep(x = 4, n = 9),
    digits = c(
      seq(from = 10, to = 50, by = 10),
      seq(from = 40, to = 10, by = -10)
    )
  )
  
  # Create data frame for annotations
  annotate_df <- df %>% 
    group_by(frameId) %>% 
    slice(1) %>% 
    mutate(down_suffix = case_when(
      down == 1 ~ "st",
      down == 2 ~ "nd",
      down == 3 ~ "rd",
      down == 4 ~ "th"),
      quarter_suffix = case_when(
        quarter == 1 ~ "st",
        quarter == 2 ~ "nd",
        quarter == 3 ~ "rd",
        quarter == 4 ~ "th"
      ),
      play_start = paste0(quarter, quarter_suffix, " Quarter, ", down,
                          down_suffix, " and ", yardsToGo,
                          " from the ", yardlineSide, " ", yardlineNumber),
      timing = paste0("Quarter: ", quarter,
                      ", Game clock: ", game_clock_abr),
      title_string = paste0("Week ", week, ", ", gameDate, " at ",
                            game_time, " | ", homeTeamAbbr, " vs. ",
                            visitorTeamAbbr),
      score = paste0(homeTeamAbbr, ": ", preSnapHomeScore, " | ",
                     visitorTeamAbbr, ": ", preSnapVisitorScore))
  
  text_size <- 3.5
  
  ggplot(data = df) +
    
    # Make middle of field green
    geom_rect(
      data = NULL,
      aes(xmin = 10, xmax = 110, ymin = 0, ymax = 53.3),
      fill = "green4", color = "black", alpha = 0.1
    ) +
    
    # Add endzones
    geom_rect(
      data = NULL,
      aes(xmin = 0, xmax = 10, ymin = 0, ymax = 53.3),
      fill = "darkslategray", color = "black", alpha = 0.1
    ) +
    geom_rect(
      data = NULL,
      aes(xmin = 110, xmax = 120, ymin = 0, ymax = 53.3),
      fill = "darkslategray", color = "black", alpha = 0.1
    ) +
    
    # Format gridlines, tick marks, tick labels, and border of plot window
    theme_bw() +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank(),
      panel.border = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank(),
      text = element_text(size = 12),
      # , legend.position = "none" # Optional hiding of legend
    ) +
    
    # Add vertical lines at each 5-yard increment
    geom_segment(
      data = five_yard_df,
      mapping = aes(x = x, xend = x, y = -Inf, yend = 53.3),
      color = "white"
    ) +
    
    # Add hash marks to field
    geom_segment(
      data = hash_df,
      mapping = aes(x = x, xend = x, y = 0.5, yend = 1.5),
      color = "white"
    ) +
    geom_segment(
      data = hash_df,
      mapping = aes(x = x, xend = x, y = 51.8, yend = 52.8),
      color = "white"
    ) +
    
    # Add yard line labels to field
    geom_text(
      data = yard_labels_df,
      mapping = aes(x = x, y = y, label = digits),
      color = "white"
    ) +
    geom_text(
      data = yard_labels_df,
      mapping = aes(x = x, y = 53.3 - y, label = digits),
      color = "white", angle = 180
    ) +
    
    # Create a final solid black outline for the field
    geom_rect(
      data = NULL,
      aes(xmin = 10, xmax = 110, ymin = 0, ymax = 53.3),
      fill = NA, color = "black"
    ) +
    
    # Add points and change colors of points in scatterplot
    geom_point(data = df, mapping = aes) +
    scale_color_manual(values = c("black", "slategray1", "red")) +
    
    # Label legend
    labs(color = "Legend") +
    
    # Add x and y axis limits
    lims(x = c(0, 120), y = c(-1, 59)) +
    
    # Add geom_text labels
    geom_text(data = annotate_df, mapping = aes(x = 0, y = 55,
                                                label = play_start),
              color = "black", hjust = 0, size = text_size) +
    geom_text(data = annotate_df, mapping = aes(x = 120, y = 55, 
                                                label = score),
              color = "black", hjust = 1, size = text_size) +
    geom_text(data = annotate_df, mapping = aes(x = 60, y = 59,
                                                label = str_wrap(playDescription, 
                                                                 80)),
              color = "black", hjust = 0.5, lineheight = 0.8, size = text_size) +
    labs(title = annotate_df$title_string[1]) +
    theme(plot.title = element_text(hjust = 0.5))
}

iter_plot <- function(df) {
  play_id <- df %>% 
    dplyr::select(playId, gameId) %>%
    unique()
  plot_football <- function(i){
    df %>%
      filter(playId == play_id$playId[i], gameId == play_id$gameId[i]) %>%
      ggfootball_for_eda(aes=aes(x = x, y = y, color = team_2, alpha = frameId)) +
      scale_alpha(range = c(0, 0.5)) +
      guides(alpha = FALSE)
  }
  map(.x = 1:nrow(play_id), .f=plot_football)
}

# make plots
plots <- filter_for_eda(route_wanted=route_wanted, 
                        all_WR=FALSE, 
                        yard_benchmark=10, 
                        max_plays = 10) %>%
  iter_plot()

# check one of the plots
plots[[1]]

# save plots as png images
map(.x = 1:length(plots), 
    ~ ggsave(filename = paste0("EDA/eda_plots/", .x,".png"), plot =plots[[.x]]))

