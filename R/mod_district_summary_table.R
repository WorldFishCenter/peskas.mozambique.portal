#' Mozambique District Summary Table UI
#' @noRd
mod_district_summary_table_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      class = "currency-selector mb-3",
      selectInput(
        ns("currency"),
        "Select Currency",
        choices = c("MZN", "USD", "EUR", "GBP"),
        selected = "MZN"
      )
    ),
    reactable::reactableOutput(ns("table"))
  )
}

#' Mozambique District Summary Table Server
#' @noRd
mod_district_summary_table_server <- function(id, data, color_pal = c("#ffffd9", "#c7e9b4", "#41b6c4")) {
  moduleServer(id, function(input, output, session) {
    # Define available currencies and their conversion rates
    currencies <- list(
      MZN = list(rate = 1, symbol = "MZN", decimals = 2),
      USD = list(rate = 0.016, symbol = "$", decimals = 2),
      EUR = list(rate = 0.015, symbol = "\u20AC", decimals = 2),
      GBP = list(rate = 0.013, symbol = "\u00A3", decimals = 2)
    )

    # Convert the data reactively based on selected currency
    converted_data <- reactive({
      req(input$currency)
      curr <- input$currency
      rate <- currencies[[curr]]$rate

      data %>%
        dplyr::transmute(
          district = .data$district,
          landing_site = .data$landing_site,
          Catch = round(.data$mean_catch_kg, 1),
          CPUE = round(.data$cpue_kg_fisher_hr, 2),
          `Trip length` = round(.data$trip_duration_hrs, 1),
          `Price per kg` = .data$price_per_kg_mzn * rate,
          `Catch Value` = .data$mean_catch_price_mzn * rate
        )
    })

    # Color and styling functions
    good_color <- grDevices::colorRamp(color_pal, bias = 2)

    normalize <- function(x, range) {
      (x - range[1]) / (range[2] - range[1])
    }

    make_style_fn <- function(range) {
      function(value) {
        normalized <- normalize(value, range)
        color <- grDevices::rgb(good_color(normalized), maxColorValue = 255)
        list(background = color)
      }
    }

    # Helper function to format currency values with appropriate decimals
    format_currency <- function(value, curr, symbol) {
      if (abs(value) < 1) {
        # For small values, show up to 3 decimal places
        formatted <- format(round(value, 3), nsmall = 3)
      } else if (abs(value) < 10) {
        # For values under 10, show 2 decimal places
        formatted <- format(round(value, 2), nsmall = 2)
      } else {
        # For larger values, use comma separator and round based on currency
        formatted <- if (curr == "MZN") {
          scales::comma(round(value, 0))
        } else {
          scales::dollar(value, digits = 2, prefix = "")
        }
      }
      paste(symbol, formatted)
    }

    output$table <- reactable::renderReactable({
      curr_data <- converted_data()
      curr <- input$currency
      symbol <- currencies[[curr]]$symbol

      # Pre-calculate ranges
      catch_range <- range(curr_data$Catch)
      value_range <- range(curr_data$`Catch Value`)
      price_range <- range(curr_data$`Price per kg`)
      cpue_range <- range(curr_data$CPUE)
      trip_range <- range(curr_data$`Trip length`)

      reactable::reactable(
        curr_data,
        theme = reactablefmtr::fivethirtyeight(centered = TRUE),
        pagination = FALSE,
        compact = TRUE,
        borderless = FALSE,
        striped = FALSE,
        fullWidth = TRUE,
        sortable = TRUE,
        defaultSorted = "district",
        defaultColDef = reactable::colDef(
          align = "center",
          minWidth = 100
        ),
        columns = list(
          district = reactable::colDef(
            name = "District",
            minWidth = 140,
            align = "left"
          ),
          landing_site = reactable::colDef(
            name = "Landing Site",
            minWidth = 140,
            align = "left"
          ),
          Catch = reactable::colDef(
            format = reactable::colFormat(digits = 1),
            cell = function(value) paste(value, "kg"),
            style = make_style_fn(catch_range)
          ),
          CPUE = reactable::colDef(
            format = reactable::colFormat(digits = 2),
            cell = function(value) paste(value, "kg"),
            style = make_style_fn(cpue_range)
          ),
          `Trip length` = reactable::colDef(
            format = reactable::colFormat(digits = 1),
            cell = function(value) paste(value, "hrs"),
            style = make_style_fn(trip_range)
          ),
          `Price per kg` = reactable::colDef(
            cell = function(value) format_currency(value, curr, symbol),
            style = make_style_fn(price_range)
          ),
          `Catch Value` = reactable::colDef(
            cell = function(value) format_currency(value, curr, symbol),
            style = make_style_fn(value_range)
          )
        )
      )
    })
  })
}
