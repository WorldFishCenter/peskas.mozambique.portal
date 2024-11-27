#' Generate content for the catch tab
#'
#' @export
tab_catch_content <- function() {
  tagList(
    tags$div(
      class = "mb-4",
      page_heading(
        pretitle = "Mozambique SSF",
        title = "Catch"
      )
    ),
    # district_selector("catch-district"),
    page_cards(
      # First row of cards - Time series and Spider plot
      tags$div(
        class = "row g-2",
        tags$div(
          class = "col-lg-8",
          card(
            title = "Catch composition",
            barchart_taxa_ui(id = "taxa_barchart")
          )
        ),
        tags$div(
          class = "col-lg-4",
          card(
            title = "Length disitribution",
            tooltip = "
  <p>This visualization shows the length distribution for the 10 most important fish groups in terms of catch:</p>
  <ul class='mb-0'>
    <li>Each bar represents the interquartile range (IQR) of fish lengths</li>
    <li>The left end shows the 25th percentile (Q1)</li>
    <li>The right end shows the 75th percentile (Q3)</li>
    <li>Longer bars indicate greater variation in fish sizes</li>
    <li>Species are ranked by their 75th percentile length</li>
  </ul>
  ",
            mod_dumbbell_ui(id = "length_dumbbell")
          )
        )
      ),
      # Second row - Treemap
      tags$div(
        class = "row g-2",
        tags$div(
          class = "col-12",
          card(
            title = "Catch rates by gear",
            tooltip = "
   <p>This visualization shows the average catch per unit of effort (CPUE) for each fishing gear type in different habitats:</p>
  <ul class='mb-0'>
    <li>CPUE is calculated as catch (kg) per fisher per hour</li>
    <li>Size of boxes indicates relative CPUE for each gear type</li>
    <li>Colors indicate different fishing habitats</li>
    <li>Higher CPUE suggests more efficient fishing methods</li>
    <li>Values are averaged across all fishing trips</li>
  </ul>
  ",
            mod_treemap_ui(id = "catch_treemap")
          )
        )
      )
    )
  )
}
