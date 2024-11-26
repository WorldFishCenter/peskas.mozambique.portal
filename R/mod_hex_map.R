#' Hex Map UI Module
#' @noRd
mod_hex_map_ui <- function(id) {
  ns <- NS(id)

  hex_colors <- get_hex_colors()
  color_styles <- vapply(seq_along(hex_colors), function(i) {
    sprintf(
      "flex: 1; background-color: rgb(%s);",
      paste(hex_colors[[i]], collapse = ",")
    )
  }, character(1))

  tags$div(
    class = "position-relative",
    style = "height: 500px;",
    map_card(
      hexagon_map(
        data = peskas.mozambique.portal::map_data,
        radius = 600
      ),
      height = "100%"
    ),
    map_info_panel(ns, color_styles)
  )
}

#' Hex Map Server Module
#' @noRd
mod_hex_map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Debounced radius input
    radius_rv <- reactive(input$radius) %>%
      debounce(100)

    # Update map when radius changes
    observeEvent(radius_rv(), {
      req(radius_rv())

      deckgl::deckgl_proxy(session$ns("map")) %>%
        deckgl::add_hexagon_layer(
          data = peskas.mozambique.portal::map_data,
          getPosition = ~ c(lon, lat),
          radius = radius_rv(),
          colorRange = get_hex_colors(),
          elevationRange = c(0, 3000),
          elevationScale = 80,
          extruded = TRUE,
          coverage = 0.8,
          pickable = TRUE,
          properties = get_hex_props(),
          tooltip = htmlwidgets::JS("window.hexagonTooltip"),
          colorAggregation = "COUNT",
          upperPercentile = 95
        ) %>%
        deckgl::update_deckgl()
    }, ignoreInit = TRUE)
  })
}

#' Create a hexagon heatmap using deckgl
#' @param data A dataframe containing lat/lon coordinates
#' @param radius Numeric. Radius of hexagons in meters
#' @return A deckgl object
#' @export
hexagon_map <- function(data,
                        radius = 600) {

  # Center coordinates for Mozambique
  center_lon <- mean(data$lon, na.rm = TRUE)
  center_lat <- mean(data$lat, na.rm = TRUE)

  # Create the map
  deckgl::deckgl(
    longitude = center_lon,
    latitude = center_lat,
    zoom = 6,
    pitch = 45,
    width = "100%",
    height = "100%",
    style = list(position = "absolute", top = 0, left = 0, right = 0, bottom = 0)
  ) %>%
    deckgl::add_basemap() %>%
    deckgl::add_hexagon_layer(
      data = data,
      getPosition = ~ c(lon, lat),
      colorRange = get_hex_colors(),
      elevationRange = c(0, 3000),
      elevationScale = 80,
      extruded = TRUE,
      radius = radius,
      coverage = 0.8,
      pickable = TRUE,
      properties = get_hex_props(),
      tooltip = htmlwidgets::JS("window.hexagonTooltip"),
      colorAggregation = "COUNT",
      upperPercentile = 95
    )
}

#' Helper function for hex colors
#' @noRd
get_hex_colors <- function() {
  list(
    c(1, 152, 189),
    c(73, 227, 206),
    c(216, 254, 181),
    c(254, 237, 177),
    c(254, 173, 84),
    c(209, 55, 78)
  )
}

#' Helper function for hex properties
#' @noRd
get_hex_props <- function() {
  list(
    autoHighlight = TRUE,
    material = list(
      ambient = 0.65,
      diffuse = 0.35,
      specularColor = c(51, 51, 51)
    ),
    transitions = list(
      elevationScale = 3000
    )
  )
}

#' Create info panel for hex map
#' @noRd
map_info_panel <- function(ns, color_styles) {
  tags$div(
    class = "card shadow-sm",
    style = "position: absolute; top: 1rem; right: 1rem; width: 300px; background: rgba(255,255,255,0.75); z-index: 1000; border: none; border-radius: 0.5rem;",
    tags$div(
      class = "card-body p-3",
      tags$h3(
        class = "card-title mb-2",
        style = "font-size: 1.2rem; font-weight: 600;",
        "Fishing Activity",
        tags$span(
          class = "ms-1",
          style = "cursor: help;",
          `data-bs-toggle` = "tooltip",
          title = "This map shows fishing vessel density across Mozambique waters",
          icon_info()
        )
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
      ),

      tags$h4(
        class = "mb-2",
        style = "font-size: 0.9rem; font-weight: 600; color: #666;",
        "Visualization Controls"
      ),
      sliderInput(
        inputId = ns("radius"),
        label = "Hex Radius (meters)",
        min = 200,
        max = 1200,
        value = 600,
        step = 100,
        ticks = FALSE
      )
    )
  )
}
