#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    apexchart_dep(),
    jquery_dep(),
    # google_analytics(),
    tabler_page(
      title = "Peskas | Mozambique",
      # Sticky navigation wrapper
      tags$div(
        class = "sticky-top",
        tags$header(
          class = "navbar navbar-expand-md navbar-light d-print-none",
          tags$div(
            class = "container-xl",
            tags$button(
              class = "navbar-toggler",
              type = "button",
              `data-bs-toggle` = "collapse",
              `data-bs-target` = "#navbar-menu",
              tags$span(class = "navbar-toggler-icon")
            ),
            tags$h1(
              class = "navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3",
              tags$a(
                href = ".",
                peskas_logo()
              )
            ),
            # district_selector_navbar("district", peskas.mozambique.portal::timeseries_month),
            tags$div(
              class = "navbar-nav flex-row order-md-last",
              version_flex(
                heading = "Management Dashboard",
                subheading = "Mozambique (0.0.0.9000 - beta)"
              ),
              # user_ui()
            )
          )
        ),
        # Navigation menu header
        tags$header(
          class = "navbar-expand-md",
          tags$div(
            class = "collapse navbar-collapse",
            id = "navbar-menu",
            tags$div(
              class = "navbar",
              tags$div(
                class = "container-xl",
                tab_menu(
                  tab_menu_item(
                    label = "Home",
                    id = "home",
                    icon_svg = icon_home()
                  ),
                  tab_menu_item(
                    label = "Catch",
                    id = "catch",
                    icon_svg = icon_scale()
                  ),
                  tab_menu_item(
                    label = "Revenue",
                    id = "revenue",
                    icon_svg = icon_currency_dollar()
                  )
                )
              )
            )
          )
        )
      ),
      # Tab content
      tabset_panel(
        menu_id = "main_tabset",
        tab_panel(
          id = "home",
          tab_home_content()
        ),
        tab_panel(
          id = "catch",
          tab_catch_content()
        ),
        tab_panel(
          id = "revenue",
          tab_revenue_content()
        )
      ),
      # Footer
      footer_panel(
        left_side_elements = tags$li(
          class = "list-inline-item",
          paste0("Last update ", Sys.Date()),
        ),
        right_side_elements = tagList(
          inline_li_link(
            content = "Licence",
            href = "https://github.com/WorldFishCenter/peskas.mozambique.portal/blob/main/LICENSE.md"
          ),
          inline_li_link(
            content = "Code",
            href = "https://github.com/WorldFishCenter/peskas.mozambique.portal"
          )
        ),
        bottom = "Copyright \u00a9 2024 Peskas. All rights reserved."
      ),
      # validation_modal()
    )
  )
}


#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @noRd
golem_add_external_resources <- function() {
  shiny::addResourcePath(
    "www", app_sys("app/www")
  )

  tags$head(
    # avoiding some overhead so that we don't need to use golem in production
    # favicon(),
    # bundle_resources(
    # path = app_sys('app/www'),
    # app_title = 'peskas.timor.portal'
    # )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}


apexchart_dep <- function() {
  htmltools::htmlDependency(
    name = "apexcharts",
    version = "3.26.2",
    src = c(href = "https://cdn.jsdelivr.net/npm/apexcharts@3.26.2/dist/"),
    script = "apexcharts.min.js"
  )
}


jquery_dep <- function() {
  htmltools::htmlDependency(
    name = "jquery",
    version = "3.6.0",
    src = c(href = "https://code.jquery.com/"),
    script = "jquery-3.6.0.min.js"
  )
}
