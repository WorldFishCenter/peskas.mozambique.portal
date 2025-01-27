#' Map UI Module
#' @param id The module ID
#' @noRd
mod_map_ui <- function(id) {
  ns <- NS(id)

  tags$div(
    class = "position-relative",
    style = "height: 500px;",
    leaflet::leafletOutput(ns("map"), height = "100%"),
    map_info_panel(ns)
  )
}

#' Map Server Module
#' @param id The module ID
#' @param data Data frame containing point data for heatmap
#' @param map SF object with district boundaries
#' @noRd
mod_map_server <- function(id, data, polygons) {
  moduleServer(id, function(input, output, session) {
    shapes <- reactive({
      polygons
    })

    output$map <- leaflet::renderLeaflet({
      req(shapes())

      leaflet::leaflet() %>%
        leaflet::addProviderTiles("Stadia.AlidadeSmooth") %>%
        leaflet.extras::addHeatmap(
          data = data,
          lng = ~lon,
          lat = ~lat,
          blur = 20,
          max = 0.3,
          radius = 15,
          minOpacity = 0.6,
          gradient = c(
            "0" = "#440154", # Dark purple
            "0.2" = "#414487", # Purple
            "0.4" = "#2a788e", # Blue
            "0.6" = "#22a884", # Green
            "0.8" = "#7ad151", # Light green
            "1.0" = "#fde725" # Yellow
          )
        ) %>%
        leaflet::addPolygons(
          data = shapes(),
          fillColor = "transparent",
          fillOpacity = 0,
          color = "grey",
          weight = 1.5,
          opacity = 0.8,
          popup = ~ paste(
            "<b>District:</b>", ADM2_PT,
            "<br><b>Province:</b>", ADM1_PT
            #"<br><b>Total surveys:</b>", n_observations
          ),
          highlightOptions = leaflet::highlightOptions(
            weight = 3.5,
            color = "black",
            opacity = 0.5,
            fillOpacity = 0.1,
            bringToFront = TRUE
          )
        ) %>%
        leaflet::setView(
          lng = 40.60337,
          lat = -10.8123,
          zoom = 9
        )
    })
  })
}

#' Create info panel for map
#' @noRd
map_info_panel <- function(ns) {
  # Viridis colors without alpha in the list
  colors <- list(
    c(68, 1, 84), # Dark purple
    c(65, 68, 135), # Purple
    c(42, 120, 142), # Blue
    c(34, 168, 132), # Green
    c(122, 209, 81), # Light green
    c(253, 231, 37) # Yellow
  )

  # Add alpha in the style string instead
  color_styles <- vapply(seq_along(colors), function(i) {
    sprintf(
      "flex: 1; background-color: rgba(%s, 0.8);", # Adding alpha of 0.8 here
      paste(colors[[i]], collapse = ",")
    )
  }, character(1))

  tags$div(
    class = "card shadow-sm",
    style = "position: absolute; top: 1rem; right: 1rem; width: 250px; background: rgba(255,255,255,0.85); z-index: 1000; border: none; border-radius: 0.5rem;",
    tags$div(
      class = "card-body p-3",
      tags$h3(
        class = "card-title mb-2",
        style = "font-size: 1.2rem; font-weight: 600;",
        "Survey Activity"
      ),
      tags$h4(
        class = "mb-2",
        style = "font-size: 0.8rem;",
        "Distribution of survey data collection points across districts"
      ),
      tags$h4(
        class = "mb-2",
        style = "font-size: 0.9rem; font-weight: 600; color: #666;",
        "Survey Density"
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
        tags$span("Sparse"),
        tags$span("Dense")
      )
    )
  )
}
