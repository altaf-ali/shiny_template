library(shiny)
library(shinydashboard)

# -----------------------------------------------------------------------------
settings_ui <- function(id, module) {
  ns <- NS(id)
  tabItem(
    tabName = id,
    h3(module$name)
  )
}

