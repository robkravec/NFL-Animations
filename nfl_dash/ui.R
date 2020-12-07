library(shiny)
library(tidyverse)
library(shinythemes)
library(shinyalert)
library(shinyWidgets)
library(DT)

# shiny pages ##################################################################

# football animation page ------------------------------------------------------

# input choices
team_choices <- c("BUF", "MIA", "NE", "NYJ")

result_choices <- list(
  "Completed Pass" = "C",
  "Incomplete Pass" = "I",
  "Interception" = "IN"
)

### page layout
# guide page -------------------------------------------------------------------

guide <- tabPanel(
  # page name
  title = "Guide",
  htmlOutput(outputId = "guide",
             style = "font-size:20px")
)

# animation page ---------------------------------------------------------------
football_animation <- tabPanel(

  # page name
  title = "Play Animation",

  # page layout
  sidebarLayout(

    # control bar
    sidebarPanel(
      tags$h4(strong("ANIMATE YOUR PLAY!")),
      width = 3,
      sliderInput(
        "week_user",
        label = "Choose the week of the play:",
        min = 1,
        max = 17,
        value = 1
      ),
      selectInput(
        inputId = "team_user",
        label = "Choose the team you want to watch:",
        choices = team_choices
      ),
      selectInput(
        inputId = "result_user",
        label = "Choose the result of the play:",
        choices = result_choices
      ),
      div(align = "center", actionButton(
        inputId = "render_anim",
        label = "Show play!",
        icon = icon("football-ball")
      ))
    ),

    # football animation
    mainPanel(
      width = 9,
      imageOutput(outputId = "football_anim_output")
    )
  )
)

# shiny ui######################################################################
shinyUI(fluidPage(

  # theme
  theme = shinytheme("sandstone"),

  # enable alert
  useShinyalert(),

  navbarPage(
    # dashboard title
    title = "NFL Dashboard",
    # guide page
    guide,
    # football animation page
    football_animation
  )
))
