library(magrittr)

config <- config::get(file = "inst/golem-config.yml")

mdb_collection_pull <- function(connection_string = NULL, collection_name = NULL, db_name = NULL) {
  # Connect to the MongoDB collection
  collection <- mongolite::mongo(collection = collection_name, db = db_name, url = connection_string)

  # Retrieve the metadata document
  metadata <- collection$find(query = '{"type": "metadata"}')

  # Retrieve all data documents
  data <- collection$find(query = '{"type": {"$ne": "metadata"}}')

  if (nrow(metadata) > 0 && "columns" %in% names(metadata)) {
    stored_columns <- metadata$columns[[1]]

    # Ensure all stored columns exist in the data
    for (col in stored_columns) {
      if (!(col %in% names(data))) {
        data[[col]] <- NA
      }
    }

    # Reorder columns to match stored order, and include any extra columns at the end
    data <- data[, c(stored_columns, setdiff(names(data), stored_columns))]
  }

  return(data)
}


valid_data <-
  mdb_collection_pull(
    connection_string = config$storage$mongodb$connection_string,
    collection_name = config$storage$mongodb$collection_name$validated,
    db_name = config$storage$mongodb$database_name
  ) %>%
  dplyr::as_tibble()


map_data <-
  valid_data %>%
  dplyr::select(lat, lon)

usethis::use_data(map_data, overwrite = T)

taxa_df <-
  valid_data %>%
  dplyr::select(submission_id, catch_df) %>%
  tidyr::unnest(catch_df, keep_empty = T) %>%
  dplyr::select(-c("n", "length_class", "counts", "catch_estimate" : "weight_bucket")) %>%
  dplyr::group_by(submission_id, catch_taxon) %>%
  dplyr::summarise(catch_gr = sum(catch_gr, na.rm = T)) %>%
  dplyr::ungroup()

usethis::use_data(taxa_df, overwrite = T)


aggregated_catch <-
  valid_data %>%
  dplyr::select(submission_id, catch_df) %>%
  tidyr::unnest(catch_df, keep_empty = T) %>%
  dplyr::group_by(submission_id) %>%
  dplyr::summarise(
    catch_kg = sum(catch_gr, na.rm = T) / 1000
  )

we <-
  valid_data %>%
  dplyr::select(submission_id, catch_outcome, landing_site, landing_date, habitat, gear, catch_price) %>%
  dplyr::left_join(aggregated_catch, by = "submission_id") %>%
  dplyr::filter(!catch_outcome == "0") %>%
  dplyr::select(-catch_outcome)


plot(we$catch_price, we$catch_kg)
