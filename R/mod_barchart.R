#' Barchart UI Function
#' @noRd
barchart_taxa_ui <- function(id) {
  ns <- NS(id)
  tagList(
    apexcharter::apexchartOutput(ns("barchart_taxa"))
  )
}

#' Barchart Server Function
#' @noRd
barchart_taxa_server <- function(id, data = NULL, colors = NULL) {
  moduleServer(id, function(input, output, session) {
    output$barchart_taxa <- apexcharter::renderApexchart({
      apexcharter::apex(
        data = data,
        type = "bar",
        mapping = apexcharter::aes(x = .data$landing_site, y = .data$catch_percent, fill = .data$catch_taxon),
        height = 500
      ) %>%
        # apexcharter::ax_tooltip(
        #  shared = FALSE,
        #  fillSeriesColor = TRUE
        # ) %>%
        apexcharter::ax_chart(
          stacked = TRUE
        ) %>%
        apexcharter::ax_colors(colors) %>%
        apexcharter::ax_xaxis(
          title = list(
            text = "Landing Site"
          )
        ) %>%
        apexcharter::ax_xaxis(
          max = 100, # Set the y-axis limit to 100
          labels = list(
            formatter = htmlwidgets::JS("function(value) { return value + '%'; }") # Add percentage to labels
          ),
          title = list(
            text = "Catch Composition"
          )
        )
    })
  })
}
