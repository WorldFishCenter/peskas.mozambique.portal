#' Dumbbell UI Function
#' @noRd
mod_dumbbell_ui <- function(id) {
  ns <- NS(id)
  tagList(
    apexcharter::apexchartOutput(ns("dumbbell"))
  )
}

#' Dumbbell Server Function
#' @noRd
mod_dumbbell_server <- function(id, data = NULL) {
  moduleServer(id, function(input, output, session) {
    output$dumbbell <- apexcharter::renderApexchart({
      apexcharter::apex(data, apexcharter::aes(catch_taxon, x = q25, xend = q75), type = "dumbbell") %>%
        apexcharter::ax_plotOptions(
          bar = apexcharter::bar_opts(
            dumbbellColors = list(list("#C9C5BA", "#70163C"))
          )
        ) %>%
        apexcharter::ax_colors("#BABABA") %>%
        apexcharter::ax_labs(
          x = "Length (cm)"
        )
    })
  })
}
