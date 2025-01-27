#' catch_ts UI Function
#' @noRd
mod_ts_ui <- function(id) {
  ns <- NS(id)
  tagList(
    apexcharter::apexchartOutput(ns("time_series_plot"), height = "400px")
  )
}

#' catch_ts Server Functions
#'
#' @noRd
#' @importFrom dplyr %>% filter
#' @importFrom apexcharter apex renderApexchart ax_yaxis ax_colors ax_legend ax_tooltip
mod_ts_server <- function(id, data, metric_col, yaxis) {
  moduleServer(id, function(input, output, session) {
    output$time_series_plot <- apexcharter::renderApexchart({
      req(metric_col())

      # Filter the data for the selected metric
      filtered_data <- data %>%
        filter(metric == metric_col())

      # Render the ApexChart
      apexcharter::apex(filtered_data,
        type = "bar",
        mapping = apexcharter::aes(
          x = date_label, # Use precomputed date labels
          y = value,
          fill = district
        )
      ) %>%
        apexcharter::ax_chart(
          toolbar = list(show = TRUE),
          animations = list(enabled = TRUE, speed = 500)
        ) %>%
        apexcharter::ax_yaxis(
          decimalsInFloat = 2,
          title = list(text = yaxis)
        ) %>%
        apexcharter::ax_xaxis(
          type = "category", # Use category for consistent labels
          title = list(text = "Date"),
          labels = list(show = TRUE)
        ) %>%
        apexcharter::ax_tooltip(
          x = list(format = "MMM yyyy")
        ) %>%
        apexcharter::ax_colors(c("#4E79A7", "#59A14F")) %>%
        apexcharter::ax_grid(
          show = TRUE,
          borderColor = "#F0F0F0",
          strokeDashArray = 0,
          position = "back"
        ) %>%
        apexcharter::ax_plotOptions(
          bar = list(
            horizontal = FALSE,
            columnWidth = "50%",
            endingShape = "flat"
          )
        ) %>%
        apexcharter::ax_legend(
          position = "bottom",
          fontSize = 15
        )
    })
  })
}
