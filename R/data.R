#' Time Series Fishing Data
#'
#' Monthly aggregated fishing data including catch amounts and prices by district
#'
#' @format A tibble with columns:
#'   \describe{
#'     \item{district}{District name where fishing occurred}
#'     \item{date}{Date rounded to the month}
#'     \item{metric}{Type of measurement ("mean_catch_kg" or "mean_catch_price")}
#'     \item{value}{Numeric value of the measurement}
#'     \item{date_label}{Formatted date string (e.g., "Jan 23")}
#'   }
"ts_data"

#' Fishing Location Data
#'
#' Geographical coordinates of valid fishing activities, cleaned to remove NA values
#'
#' @format A data frame with columns:
#'   \describe{
#'     \item{lat}{Latitude coordinate}
#'     \item{lon}{Longitude coordinate}
#'   }
#' @details Data has been cleaned to remove any NA values in coordinates
"map_data"

#' District Boundaries with Survey Counts
#'
#' Spatial data for Palma and Mocimboa Da Praia districts including the count of survey points within each district
#'
#' @format A simple feature collection with columns:
#'   \describe{
#'     \item{ADM2_PT}{District name in Portuguese}
#'     \item{ADM2_PCODE}{District administrative code}
#'     \item{ADM1_PT}{Province name in Portuguese (Cabo Delgado)}
#'     \item{ADM1_PCODE}{Province administrative code}
#'     \item{ADM0_EN}{Country name in English (Mozambique)}
#'     \item{ADM0_PT}{Country name in Portuguese (Moçambique)}
#'     \item{n_observations}{Number of survey points falling within each district}
#'     \item{geometry}{MULTIPOLYGON geometry defining district boundaries}
#'   }
#' @details Districts are filtered to include only Palma and Mocimboa Da Praia.
#'   Survey points are counted using spatial intersection with district polygons.
"mozamap_with_counts"

#' Taxa Catch Data
#'
#' Detailed catch data by taxonomic group
#'
#' @format A tibble with columns:
#'   \describe{
#'     \item{submission_id}{Unique identifier for each submission}
#'     \item{catch_taxon}{Taxonomic classification of the catch}
#'     \item{catch_gr}{Catch weight in grams}
#'   }
"taxa_df"

#' Aggregated Landing Site Data
#'
#' Summary statistics for fishing activities by district and landing site
#'
#' @format A tibble with columns:
#'   \describe{
#'     \item{district}{District name}
#'     \item{landing_site}{Name of the landing site}
#'     \item{trip_duration_hrs}{Mean trip duration in hours}
#'     \item{cpue_kg_fisher_hr}{Mean catch per unit effort (kg/fisher/hour)}
#'     \item{price_per_kg_mzn}{Mean price per kilogram in Mozambican Metical}
#'     \item{mean_catch_kg}{Mean catch in kilograms}
#'     \item{mean_catch_price_mzn}{Mean catch price in Mozambican Metical}
#'   }
"tab_data"

#' Taxa Summary by Landing Site
#'
#' Summary of catch composition by taxa at each landing site
#'
#' @format A tibble with columns:
#'   \describe{
#'     \item{landing_site}{Name of the landing site}
#'     \item{catch_taxon}{Taxonomic classification (top 6 taxa and "Other")}
#'     \item{catch_kg}{Total catch in kilograms}
#'     \item{catch_percent}{Percentage of total catch}
#'   }
#' @details Top 6 taxa are identified based on total catch weight, with remaining taxa
#'   grouped as "Other"
"taxa_summary"

#' Treemap Plot Data for CPUE and RPUE
#'
#' Hierarchical data structure for creating treemap visualizations of Catch Per Unit
#' Effort (CPUE) and Revenue Per Unit Effort (RPUE) by habitat and gear type
#'
#' @format A list containing two elements (cpue and rpue), each with nested structure:
#'   \describe{
#'     \item{habitat}{Primary grouping level representing fishing habitats}
#'     \item{gear}{Secondary level showing fishing gear types}
#'     \item{value}{Measurement value (CPUE or RPUE)}
#'   }
#' @details CPUE is measured in kg/fisher/hour and RPUE in currency/fisher/hour
"treeplot_data"

#' Fish Length Data
#'
#' Length statistics for the top 11 taxa by catch weight
#'
#' @format A tibble with columns:
#'   \describe{
#'     \item{catch_taxon}{Taxonomic classification}
#'     \item{q25}{25th percentile of length distribution}
#'     \item{q75}{75th percentile of length distribution}
#'     \item{min}{Minimum recorded length}
#'     \item{max}{Maximum recorded length}
#'   }
#' @details Length measurements are weighted by count frequency. Taxa names are
#'   simplified for some groups (e.g., "Tuna/Bonito/Other Mackerel" to "Tuna/Bonito")
"length_data"
