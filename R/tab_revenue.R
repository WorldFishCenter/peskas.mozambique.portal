#' Generate content for the revenue tab of the Mozambique small scale fisheries dashboard
#'
#' @description
#' This function creates the layout and content for the revenue tab of the dashboard.
#' It includes a time series plot and a revenue distribution plot.
#'
#' @return A tagList containing the structured content for the revenue tab
#'
#' @export
tab_revenue_content <- function() {
  tagList(
    tags$div(
      class = "mb-4",
      page_heading(
        pretitle = "Mozambique SSF",
        title = "Revenue"
      )
    ),
    # district_selector("revenue-district"),
    page_cards(
      tags$div(
        class = "row g-2"
      ),
      tags$div(
        class = "row g-2",
        tags$div(
          class = "col-12",
          card(
            title = "Revenue rates by gear",
            tooltip = "
 <p>This visualization shows the average revenue per unit of effort (RPUE) for each fishing gear type in different habitats:</p>
  <ul class='mb-0'>
    <li>RPUE is calculated as revenue (MZM) per fisher per hour</li>
    <li>Size of boxes indicates relative RPUE for each gear type</li>
    <li>Colors indicate different fishing habitats</li>
    <li>Higher RPUE suggests more profitable fishing methods</li>
    <li>Values are averaged across all fishing trips</li>
  </ul>
  ",
            mod_treemap_ui("revenue_treemap")
          )
        )
      )
    )
  )
}
