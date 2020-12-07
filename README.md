# NFL Animations

## Context

This repository is an excerpt from an end of course team project for Duke's STA 523 
(Statistical Programming) course. The files contained are meant to showcase my
contribution to the project (the development of the animated plots).

To view a representative animation, please see our Shiny [app](https://rob-kravec.shinyapps.io/nfl_dash/?_ga=2.56872490.1609727935.1605974938-1036932365.1605974938).

## Inspiration

Our project is inspired by the NFL's Big Data Bowl 2021 on Kaggle, which challenges teams to 
generate novel insights on defending passing plays. While this project is not specifically 
aimed at this goal, the rich player tracking data provided by the competition enables us to 
both build interesting plots (animated and still) and a predictive model. 

## Main objective

This project has 2 main objectives:

- Generate animated plots based on user input to visualize NFL plays from a bird's-eye view
- Predict the outcome of a play (in terms of yardage gained) based on solely pre-snap information

## Data

Our data, sourced from the NFL's Big Data Bowl 2021 on Kaggle, contains 4 types of files.
Please note that all information in these files pertains to passing plays in the 2018 NFL season:

- Game data: Logistics about each game, including the time, data, and teams playing
- Play data: One line summary for each play, including context (e.g., location on field, 
time remaining in game, score), team formations, and play outcome (e.g., yardage gained)
- Tracking data: Position (i.e., x and y coordinates) and movement (e.g., speed, acceleration) 
measurements for each player at points in time. Offensive and defensive linemen are largely excluded
- Player data (not used for this project): Identifying information for NFL players

Please see below for a couple of static plots, which demonstrate the richness of the tracking data:

![](./EDA/eda_plots/1.png)

![](./EDA/eda_plots/74_yards.png)

## Methods

#### Animated plotting

The Tracking data files are ~ 2GB in total, which is too large to include on shinyapp.io 
with a free account. As a result, we (1) limit our animations to only AFC East teams 
(Buffalo Bills, Miami Dolphins, New England Patriots, New York Jets) and (2) take a 
30% stratified sample from each week. With this reduced data set, we are then able 
to produce animations with gganimate. 

In the Shiny app, users are able to specify a week, team, and play outcome. If no plays 
in our sampled data set fit the criteria, a warning message is returned. If multiple 
plays in our sampled data set fit the criteria, then one of the plays is randomly 
chosen to be displayed in the plot.

#### Predictive modeling

To build our predictive model we wanted to extract as much information from 
our play data as well the player tracking data. 

In the model development stage we attempted a random forest, gradient boosted
tree, as well a elastic net regression. Each method produce dissatisfying results
generating an root mean squared error of no less than 9. Given the difficulty 
in producing accurate point estimates we opted for a quantile regression. We
predict the 12.5% quantile and the 87.5% quantile to estimate a 75% confidence 
region for the expected yards gained. For our point estimate we model the 
median yards gained using a quantile regression. 

** Please note that the files associated with our predictive model are not
contained within this repository. Rather, the data set used for generating the
animated plots contains the predictions.

## Results

We should note that the predictive performance of our model is very poor. This is not
unexpected as almost all of our feature variables were uncorrelated with response
variable, the yards gained on the play. There are a couple points to consider.

1) A large number of plays are incomplete and have 0 yards gained.

2) There are a non insignificant amount of large break away plays. 

Clearly our model over compensates for the large number of 0 yards gain and is 
unable to capture the plays with larger yards gain as almost all our predictions
are between 0 and 10 yards.

It is important to mention that this is a difficult problem to solve and, in 
fact, front offices have yet to find an adequate solution.

## Acknowledgements

This project was completed as part of STA 523 (Statistical Programming) at Duke, taught by Professor Shawn Santo. 
Three of my classmates, Marc Brooks, Yue Han, and Cathy Shi collaborated with me on this project.

## References

- NFL Big Data Bowl 2021 (data, notebooks of competition competitors for 
visualziation inspiration): https://www.kaggle.com/c/nfl-big-data-bowl-2021/overview
- Stratified sampling: https://www.rdocumentation.org/packages/splitstackshape/versions/1.4.8/topics/stratified
- Gradient Boosting model: https://datascienceplus.com/gradient-boosting-in-r/
- Embed gganimation in shiny: https://stackoverflow.com/questions/35421923/how-to-create-and-display-an-animated-gif-in-shiny
