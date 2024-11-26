#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  habitat_palette <- c("#440154", "#30678D", "#35B778", "#FDE725", "#FCA35D", "#D32F2F", "#67001F")
  habitat_colors <- habitat_palette %>% strtrim(width = 7)


  mod_heatmap_server("heatmap")
  mod_district_summary_table_server("district_table", data = peskas.mozambique.portal::tab_data)

  mod_treemap_server(id = "catch_treemap", data = peskas.mozambique.portal::treeplot_data$cpue , type = "cpue", colors = habitat_colors)

  mod_treemap_server(id = "revenue_treemap", data = peskas.mozambique.portal::treeplot_data$rpue , type = "rpue", colors = habitat_colors)

}
