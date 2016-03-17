# -----------------------------------------------------------------------------
dashboard_name <- function(s, prefix = NULL) {
  paste(c(prefix, gsub("\\s|[[:punct:]]", "_", tolower(s))), collapse = "_")
}

# -----------------------------------------------------------------------------
dashboard_tab <- function(s) {
  dashboard_name(s, "tab")
}

# -----------------------------------------------------------------------------
dashboard_menuItem <- function(item) {
  menuItem(item$name, tabName = dashboard_tab(item$name), icon = item$icon)
}

# -----------------------------------------------------------------------------
dashboard_conditionalMenuItem <- function(item) {
  module_name <- dashboard_tab(item$name)
  conditionalPanel(
    condition = sprintf("input.sidebar_menu == '%s'", module_name),
    hr(),
    do.call(paste0(module_name, "_sidebar"), args = list(module_name))
  )
}

# -----------------------------------------------------------------------------
dashboard_tabItem <- function(item) {
  module_name <- dashboard_name(item$name)
  do.call(paste0(module_name, "_input"), args = list(module_name))
}