library(yaml)
library(shiny)
library(shinydashboard)

# -----------------------------------------------------------------------------
dashboard_config <- function() {
  yaml.load_file('dashboard.yml')
}

# -----------------------------------------------------------------------------
dashboard_load_modules <- function(modules) {
  for (i in seq_along(modules)) {
    filename <- paste(names(modules)[i], "R", sep=".")
    if (file.exists(filename)) 
      source(filename)
  }
}

# -----------------------------------------------------------------------------
dashboard_header <- function(title) {
  dashboardHeader(title = title)
}

# -----------------------------------------------------------------------------
dashboard_sidebar <- function(modules) {
  dashboardSidebar(sidebarMenu(id = "sidebar_menu", 
                               dashboard_menuItems(modules),
                               dashboard_menuItemsConditional(modules)))
}

# -----------------------------------------------------------------------------
dashboard_body <- function(modules) {
  dashboardBody(do.call(tabItems, dashboard_tabItems(modules)))
}

# -----------------------------------------------------------------------------
dashboard_func <- function(id, func) {
  paste0(id, "_", func)
}

# -----------------------------------------------------------------------------
dashboard_call <- function(id, module, func) {
  func_obj <- dashboard_func(id, func)
  if (exists(func_obj)) {
    do.call(func_obj, args = list(id = id, module = module))
  }
  else {
    #warning(sprintf("function '%s' does not exist for module '%s'", func, id))
  }
}

# -----------------------------------------------------------------------------
dashboard_menuItem <- function(id, module) {
  menuItem(module$name, tabName = id, icon = icon(module$icon))
}

# -----------------------------------------------------------------------------
dashboard_menuItems <- function(modules) {
  lapply(seq_along(modules), function(i) {
    dashboard_menuItem(names(modules)[i], modules[[i]])
  })
}

# -----------------------------------------------------------------------------
dashboard_menuItemsConditional <- function(modules) {
  lapply(seq_along(modules), function(i) {
    id <- names(modules)[i]
    module <- modules[[i]]
    conditional_items <- dashboard_call(id, module, "sidebar")
    if (length(conditional_items))
      conditional_items <- list(hr(), conditional_items)
    conditionalPanel(
      condition = sprintf("input.sidebar_menu == '%s'", id),
      conditional_items
    )
  })
}

# -----------------------------------------------------------------------------
dashboard_tabItems <- function(modules) {
  items <- lapply(seq_along(modules), function(i) {
    dashboard_call(names(modules)[i], modules[[i]], "ui")
  })
  items[!sapply(items, is.null)] 
}

# -----------------------------------------------------------------------------
dastboard_setActiveTab <- function(session, id) {
  updateTabItems(session, "sidebar_menu", selected = id)
}

# -----------------------------------------------------------------------------
dashboard_server <- function(modules, input, output, session) {
  for (i in seq_along(modules)) {
    id <- names(modules)[i]
    module <- modules[[i]]
    func <- dashboard_func(id, "server")
    if (exists(func)) 
      callModule(function(input, output, session) {
        do.call(func, args = list(input, output, session, id, module))
      }, id = id, session = session)
  }

  dastboard_setActiveTab(session, names(modules)[1])
}

# -----------------------------------------------------------------------------
dashboard_app <- function() {
  app <- dashboard_config()
  
  dashboard_load_modules(app$modules)
  
  header <- dashboard_header(app$title)
  sidebar <- dashboard_sidebar(app$modules)
  body <- dashboard_body(app$modules)
  
  server <- function(input, output, session) {
    dashboard_server(app$modules, input, output, session)
  }
  
  shinyApp(ui = dashboardPage(header, sidebar, body), server = server)
}

