library(shiny)
library(shinydashboard)

library(tidyverse)
library(ggvis)

# -----------------------------------------------------------------------------
home_sidebar <- function(id, module) {
  ns <- NS(id)
  list(
    selectInput(ns("color"), "Color", choices = c("red", "blue", "green"))
  )
}

# -----------------------------------------------------------------------------
home_ui <- function(id, module) {
  ns <- NS(id)
  tabItem(
    tabName = id,
    h3(module$name),
    fluidRow(
      box(width = 12, title = "Scatter Plot", ggvisOutput(ns("plot_scatter")))
    )
  )
}

# -----------------------------------------------------------------------------
home_server <- function(input, output, session, id, module) {
  ns <- NS(id)
  
  data <- data.frame(x = rnorm(100)) %>% 
    mutate(y = x^2)
  
  reactive({
    data %>%
      ggvis(x = ~x, y = ~y) %>%
      layer_points(fill := input$color)
  }) %>%
  bind_shiny(ns("plot_scatter"))
}
