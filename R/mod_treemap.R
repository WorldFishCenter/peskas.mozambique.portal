#' Treemap UI Function
#' @noRd
mod_treemap_ui <- function(id) {
  ns <- NS(id)
  tagList(
    apexcharter::apexchartOutput(ns("treemap"), height = "400px")
  )
}

#' Treemap Server Function
#' @noRd
mod_treemap_server <- function(id, data = NULL, type = NULL, colors = NULL) {
  moduleServer(id, function(input, output, session) {
    suffix <- if (type == "cpue") " kg/hrs" else " MZM/hrs"

    output$treemap <- apexcharter::renderApexchart({
      apexcharter::apexchart() %>%
        apexcharter::ax_chart(
          type = "treemap",
          toolbar = list(show = FALSE),
          animations = list(
            enabled = TRUE,
            speed = 800,
            animateGradually = list(enabled = TRUE)
          ),
          selection = list(enabled = FALSE),
          zoom = list(enabled = FALSE)
        ) %>%
        apexcharter::ax_series2(data) %>%
        apexcharter::ax_legend(
          show = TRUE,
          fontSize = 15,
          position = "top",
          onItemClick = FALSE
        ) %>%
        apexcharter::ax_colors(colors) %>%
        apexcharter::ax_tooltip(
          shared = FALSE,
          followCursor = TRUE,
          intersect = TRUE,
          fillSeriesColor = FALSE
        ) %>%
        apexcharter::ax_dataLabels(
          enabled = TRUE,
          formatter = V8::JS(sprintf("function (text, op) {return [text, op.value.toFixed(2) + '%s']}", suffix))
        )
    })
  })
}
