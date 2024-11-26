#' Heatmap Map UI Module
#' @noRd
mod_heatmap_ui <- function(id) {
  ns <- NS(id)

  # Define colors for the legend
  colors <- list(
    c(1, 152, 189),
    c(73, 227, 206),
    c(216, 254, 181),
    c(254, 237, 177),
    c(254, 173, 84),
    c(209, 55, 78)
  )

  # Create color styles for the legend
  color_styles <- vapply(seq_along(colors), function(i) {
    sprintf(
      "flex: 1; background-color: rgb(%s);",
      paste(colors[[i]], collapse = ",")
    )
  }, character(1))

  tags$div(
    class = "position-relative",
    style = "height: 500px;",
    map_card(
      heatmap_map(
        data = peskas.mozambique.portal::map_data
      ),
      height = "100%"
    ),
    map_info_panel(ns, color_styles)
  )
}

#' Heatmap Map Server Module
#' @noRd
mod_heatmap_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Empty server since we removed interactive features
  })
}

#' Create a heatmap using deckgl
#' @param data A dataframe containing lat/lon coordinates
#' @return A deckgl object
#' @export
heatmap_map <- function(data) {
  # Center coordinates for Mozambique
  center_lat <- -10.8123
  center_lon <- 40.60337

  # Create the map
  deckgl::deckgl(
    longitude = center_lon,
    latitude = center_lat,
    zoom = 8,
    pitch = 0,
    width = "100%",
    height = "100%"
  ) %>%
    deckgl::add_basemap() %>%
    deckgl::add_layer(
      "HeatmapLayer",
      data = data,
      getPosition = ~ c(lon, lat),
      radiusPixels = 30,
      intensity = 1,
      threshold = 0.1,
      colorRange = list(
        c(1, 152, 189),
        c(73, 227, 206),
        c(216, 254, 181),
        c(254, 237, 177),
        c(254, 173, 84),
        c(209, 55, 78)
      )
    )
}

#' Create info panel for heatmap
#' @noRd
map_info_panel <- function(ns, color_styles) {
  tags$div(
    class = "card shadow-sm",
    style = "position: absolute; top: 1rem; right: 1rem; width: 250px; background: rgba(255,255,255,0.65); z-index: 1000; border: none; border-radius: 0.5rem;",
    tags$div(
      class = "card-body p-3",
      tags$h3(
        class = "card-title mb-2",
        style = "font-size: 1.2rem; font-weight: 600;",
        "Fishing Activity"
      ),
      tags$h4(
        class = "mb-2",
        style = "font-size: 0.8rem;",
        "This map shows survey activity density in Palma and Mocimboa districts"
      ),
      tags$h4(
        class = "mb-2",
        style = "font-size: 0.9rem; font-weight: 600; color: #666;",
        "Activity Density"
      ),
      tags$div(
        class = "mb-1",
        style = "display: flex; height: 20px;",
        lapply(seq_along(color_styles), function(i) {
          tags$div(style = color_styles[i])
        })
      ),
      tags$div(
        class = "d-flex justify-content-between text-muted mb-3",
        style = "font-size: 0.8rem;",
        tags$span("Low"),
        tags$span("High")
      )
    )
  )
}
