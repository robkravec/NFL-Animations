### This script is used to generate an animated plot for a single play 
### contained within the tracking data for the NFL Big Data Bowl 2021 
### competition found on Kaggle: 
### https://www.kaggle.com/c/nfl-big-data-bowl-2021/overview

# Load libraries
library(vroom)
library(tidyverse)
library(gganimate)
library(ggExtra)
library(gifski)

# Source ggfootball function
source(file = "ggfootball.R")

# Load data for testing
#if (!exists("merged_data")) {
#  merged_data <- vroom("../data/merged_data.csv.gz")
#}

# Create function to plot a single play (using ggfootball)
animate_play <- function(df,
                         week_user = "",
                         team_user = "",
                         result_user = "") {
  
  # Initialize user_df for filtering based on user inputs
  user_df <- df
  
  # Create filtered data frame based on user inputs
  if(!(week_user == "")) {
    user_df <- user_df %>% 
      filter(week == week_user)
  }
  
  if(!(team_user == "")) {
    user_df <- user_df %>% 
      filter(possessionTeam == team_user)
  }
  
  if(!(result_user == "")) {
    user_df <- user_df %>% 
      filter(passResult == result_user)
  }
  
  # Safeguard to ensure that resulting data frame has at least one row
  if(nrow(user_df) == 0) {
    warning("There is no play in the data set that fits this description.")
    return("")
  }
  
  # Randomly sample a play from the supplied data frame
  sample_row <- sample(x = 1:nrow(user_df), size = 1)
  sample_play <- user_df[sample_row, "playId"]
  sample_game <- user_df[sample_row, "gameId"]
  
  # Filter data frame for that play, game combination
  filtered_df <- user_df %>% 
    filter(playId == sample_play$playId, gameId == sample_game$gameId) %>% 
    arrange(frameId)
  
  # Create data frame for annotations
  annotate_df <- filtered_df %>% 
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
        quarter == 4 ~ "th",
        TRUE ~ ""
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
  
  # Create a ggplot object from filtered data frame
  gplot <- ggplot(data = filtered_df, mapping = aes(x = x, y = y, 
                                                    color = team_2))
  
  text_size <- 6
  
  # Generate animated plot
  animated_plot <- ggfootball(gplot) +
    transition_manual(frames = frameId) +
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
    
    ### Add model predictions
    
    # Quantile predictions
    geom_rect(data = annotate_df,
              mapping = aes(xmin = lwr_end, xmax = upr_end,
                            ymin = 0, ymax = 53.3,
                            fill = "75% predicted interval"),
              color = "cornsilk2", alpha = 0.4) +
    
    # Point prediction
    geom_segment(data = annotate_df, 
                 mapping = aes(x = est_end, xend = est_end,
                               y = 0, yend = 53.3, fill = "Point prediction"),
                               color = "gray45", size = 0.8) +
    
    # Add points, and select colors
    geom_point(size = 4) +
    scale_color_manual(values = c("black", "slategray1", "red")) +
    scale_fill_manual(values = c("cornsilk2", "gray45")) +
    
    # Add title
    labs(title = annotate_df$title_string[1],
         fill = "Prediction key") +
    theme(plot.title = element_text(hjust = 0.5, size = 24))
  
  # Run animation
  animate(plot = animated_plot, 
          nframes = length(unique(filtered_df$frameId)),
          detail = 10, fps = 10, end_pause = 10,
          width = 900, 
          height = 650)
}

