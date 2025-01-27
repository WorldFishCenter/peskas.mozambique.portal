#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  habitat_palette <- c("#440154", "#30678D", "#35B778", "#FDE725", "#FCA35D", "#D32F2F", "#67001F")
  habitat_colors <- habitat_palette %>% strtrim(width = 7)

  taxa_palette <- viridisLite::turbo(15, alpha = 0.75)
  taxa_colors <- taxa_palette %>% strtrim(width = 15)

  #map_data <- stats::na.omit(as.data.frame(peskas.mozambique.portal::map_data))
  #mozamap <-
  #  sf::read_sf(system.file("palma_area.geojson", package = "peskas.mozambique.portal")) |>
  #dplyr::filter(ADM2_PT %in% c("Mocimboa Da Praia", "Palma"))

  #points_sf <- map_data %>%
  #sf::st_as_sf(
  #  coords = c("lon", "lat"),
  #  crs = sf::st_crs(mozamap)
  #)

# Count points in each polygon and join back to mozamap
#mozamap_with_counts <- 
#  mozamap %>%
#  dplyr::mutate(
#    n_observations = lengths(sf::st_intersects(geometry, points_sf))
#  )

  mod_map_server("leafmap", data = peskas.mozambique.portal::map_data, polygons = peskas.mozambique.portal::mozamap_with_counts)
  mod_district_summary_table_server("district_table", data = peskas.mozambique.portal::tab_data)

  mod_ts_server(id = "catch_ts", data = peskas.mozambique.portal::ts_data, metric_col = reactive("mean_catch_kg"), yaxis = "Mean catch per trip (kg)")
  barchart_taxa_server(id = "taxa_barchart", data = peskas.mozambique.portal::taxa_summary, colors = taxa_colors)
  mod_dumbbell_server(id = "length_dumbbell", data = peskas.mozambique.portal::length_data)
  mod_treemap_server(id = "catch_treemap", data = peskas.mozambique.portal::treeplot_data$cpue, type = "cpue", colors = habitat_colors)

  mod_ts_server(id = "revenue_ts", data = peskas.mozambique.portal::ts_data, metric_col = reactive("mean_catch_price"), yaxis = "Mean revenue per trip (MZN)")
  mod_treemap_server(id = "revenue_treemap", data = peskas.mozambique.portal::treeplot_data$rpue, type = "rpue", colors = habitat_colors)
}
