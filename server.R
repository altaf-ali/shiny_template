# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinydashboard)

source("config.R")

shinyServer(function(input, output, session) {
  
  modules <- list(
  )
  
  sapply(modules, function(item) { 
    callModule(item$server, id = item$name) 
  })
})

