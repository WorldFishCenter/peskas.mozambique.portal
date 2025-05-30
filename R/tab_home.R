#' Generate content for the home tab of the Mozambique small scale fisheries dashboard
#'
#' @description
#' This function creates the layout and content for the home tab of the dashboard.
#' It includes a page heading, three small cards with time series plots, a map card,
#' and a district summary table.
#'
#' @return A tagList containing the structured content for the home tab
#'
#' @details
#' The function uses the following components:
#' - page_heading: Sets the title and subtitle for the page
#' - small_card: Creates cards for number of submissions, vessels surveyed, and catches recorded
#' - homecard_ts_plot: Generates time series plots for each small card
#' - map_card: Displays a hexagon map of the data
#' - hexagon_map: Creates the hexagon map using Mapbox
#' - district_summary_table: Generates a summary table of district data
#'
#' @note
#' Requires access to peskas.mozambique.portal data and a valid Mapbox token
#'
#' export
tab_home_content <- function() {
  tagList(
    page_heading(
      pretitle = "Mozambique SSF",
      title = "Home"
    ),
    alert(
      title = "Beta Version",
      message = "This application is currently in beta testing phase. Some features and data may be incomplete or incorrect."
    ),
    page_cards(
      # Second row - Map
      tags$div(
        class = "row g-2",
        tags$div(
          class = "col-12",
          mod_map_ui("leafmap")
        )
      ),
      # Third row - District summary table
      tags$div(
        class = "row g-2",
        tags$div(
          class = "col-12",
          card(
            title = "Districts summary",
            tooltip = "
          <p>This table shows the average values per fishing trip for each landing site:</p>
          <ul class='mb-0'>
            <li>Catch: Average catch per trip (kg)</li>
            <li>CPUE: Average catch per fisher per hour (kg/fisher/hr)</li>
            <li>Trip length: Average trip duration (hrs)</li>
            <li>Price per kg: Average price per kilogram</li>
            <li>Catch Value: Average catch value per trip</li>
          </ul>",
            placement = "right",
            mod_district_summary_table_ui("district_table")
          )
        )
      )
    )
  )
}
