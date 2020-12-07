library(shiny)
library(tidyverse)
library(shinythemes)
library(shinyalert)
library(shinyWidgets)
library(plotly)
library(DT)

source("animate_play.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  # Read in data
  showModal(modalDialog("Loading data...", footer = NULL))
  merged_data <- vroom(file = "data/merged_data_predictions.csv.gz")
  removeModal()
  
  # a reference of embed gganimation to shiny
  # https://stackoverflow.com/questions/35421923/how-to-create-and-display-an-animated-gif-in-shiny
  # the solution is to save a temp gif and use renderImage
  a <- eventReactive(input$render_anim, {
    # a reference of loading msg
    # https://stackoverflow.com/questions/17325521/r-shiny-display-loading-message-while-function-is-running
    showModal(modalDialog("Rendering animation...", footer=NULL))
    a <- animate_play(df = merged_data,
      result_user = input$result_user,
      week_user = input$week_user,
      team_user = input$team_user
    )
    removeModal()
    a
  })
  
  observeEvent(input$render_anim, {
      if (a() == "") {
          shinyalert(
              title = "No play record, Please try other options!",
              type = "warning"
          )
      }
  })
  
  output$football_anim_output <- renderImage({
      outfile <- tempfile(fileext = ".gif")
      
      tryCatch({
          anim_save("outfile.gif", a())
          },
          error = function(e) {
              NULL
          })

      list(
        src = "outfile.gif",
        contentType = "image/gif",
        width = 900,
        height = 650,
        alt = ""
      )
    },
    deleteFile = TRUE
  )
  
  # Create description for guide page
  output$guide <- renderText({
    paste0(
      "This app allows users to view animated NFL plays from the 2018 season ",
      "based on a specified week number, offensive team, and play result. ",
      "The data set is sourced from the NFL Big Data Bowl 2021 competition on ",
      "Kaggle ",
      "(<a href = 'https://www.kaggle.com/c/nfl-big-data-bowl-2021/overview'>",
      "https://www.kaggle.com/c/nfl-big-data-bowl-2021/overview</a>). The ",
      "purpose of the competition is to find novel insights about how to best ",
      "depend passing plays. As a result, the data set only contains passing ",
      "plays, and linemen (offensive and defensive) are rarely pictured. ",
      "The size of the full data set is quite large (~2 GB), so a sample of ",
      "approximately 25 plays from each week is available for animation. ",
      "To increase the likelihood that a play will be available that matches ",
      "the user's specifications, the data set has been filtered to only ",
      "contain plays in which AFC East teams are on offense.",
      "<br/> <br/> In addition to displaying animated plots, this app also ",
      "showcases the output of a model that predicts the number of yards that ",
      "a play will successfully advance, based only on pre-snap information. ",
      "This prediction is then compared to the true outcome in each ",
      "animation. In an attempt to improve model accuracy, the data set is ",
      "filtered to remove sacks, penalties and game situations that are deemed ", 
      "not to be competitive (e.g., a score differential of at least 21 points)."
    )
  })
})

