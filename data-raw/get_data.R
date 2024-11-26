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
  dplyr::select(-c("n", "length_class", "counts", "catch_estimate":"weight_bucket")) %>%
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

tab_data <-
  valid_data %>%
  dplyr::left_join(aggregated_catch, by = "submission_id") %>%
  dplyr::filter(!catch_outcome == "0" & catch_kg > 0) %>%
  dplyr::filter(tot_fishers != 0 & trip_duration != 0) %>%
  dplyr::mutate(
    price_kg = catch_price / catch_kg,
    cpue = (catch_kg / tot_fishers) / trip_duration
  ) %>%
  dplyr::group_by(district, landing_site) %>%
  dplyr::summarise(
    trip_duration_hrs = mean(trip_duration, na.rm = T),
    cpue_kg_fisher_hr = mean(cpue, na.rm = T),
    price_per_kg_mzn = mean(price_kg, na.rm = T),
    mean_catch_kg = mean(catch_kg, na.rm = T),
    mean_catch_price_mzn = mean(catch_price, na.rm = T)
  ) %>%
  dplyr::ungroup()

usethis::use_data(tab_data, overwrite = T)


top_6_taxa <-
  valid_data %>%
  dplyr::filter(!catch_outcome == "0") %>%
  dplyr::select(district, landing_site, catch_df) %>%
  tidyr::unnest(catch_df, keep_empty = T) %>%
  dplyr::group_by(catch_taxon) %>%
  dplyr::summarise(catch_kg = sum(catch_gr, na.rm = T) / 1000) %>%
  dplyr::arrange(-catch_kg, .by_group = T) %>%
  dplyr::slice_head(n = 15) %>%
  dplyr::pull(catch_taxon)


taxa_summary <-
  valid_data %>%
  dplyr::filter(!catch_outcome == "0") %>%
  dplyr::select(district, landing_site, catch_df) %>%
  tidyr::unnest(catch_df, keep_empty = T) %>%
  dplyr::mutate(catch_taxon = ifelse(catch_taxon %in% top_6_taxa, catch_taxon, "Other")) %>%
  dplyr::group_by(landing_site) %>%
  dplyr::mutate(tot_catch_kg = sum(catch_gr, na.rm = T) / 1000) %>%
  dplyr::group_by(landing_site, catch_taxon) %>%
  dplyr::summarise(
    landing_site = dplyr::first(landing_site),
    catch_kg = sum(catch_gr, na.rm = T) / 1000,
    tot_catch_kg = dplyr::first(tot_catch_kg),
    catch_percent = (catch_kg / tot_catch_kg) * 100
  ) %>%
  dplyr::select(-tot_catch_kg) %>%
  dplyr::ungroup() %>%
  na.omit() %>%
  tidyr::complete(landing_site, catch_taxon, fill = list(catch_kg = 0, catch_percent = 0)) %>%
  dplyr::mutate(dplyr::across(c("catch_kg", "catch_percent"), ~ round(., 2)))

usethis::use_data(taxa_summary, overwrite = T)


base_data <- valid_data %>%
  dplyr::left_join(aggregated_catch, by = "submission_id") %>%
  dplyr::filter(!catch_outcome == "0" & catch_kg > 0, tot_fishers != 0 & trip_duration != 0) %>%
  dplyr::mutate(
    cpue = (catch_kg / tot_fishers) / trip_duration,
    rpue = (catch_price / tot_fishers) / trip_duration,
  ) %>%
  dplyr::group_by(habitat, gear) %>%
  dplyr::summarise(
    cpue = mean(cpue, na.rm = TRUE),
    rpue = mean(rpue, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::mutate(
    cpue = round(cpue, 3),
    rpue = round(rpue, 3)
  ) %>%
  tidyr::pivot_longer(cols = c(cpue, rpue), names_to = "metric", values_to = "value") %>%
  dplyr::ungroup() %>%
  tidyr::complete(habitat, gear, metric, fill = list(value = NA_real_)) %>%
  dplyr::filter(value > 0) %>%
  split(.$metric) %>%
  purrr::map(~ .x %>% dplyr::select(-metric)) %>%
  # Calculate totals and order habitats
  purrr::map(~ .x %>%
    dplyr::group_by(habitat) %>%
    dplyr::mutate(tot = sum(value)) %>%
    dplyr::arrange(dplyr::desc(tot)) %>%
    # Within each habitat, order by individual values
    dplyr::arrange(dplyr::desc(tot), habitat, dplyr::desc(value)) %>%
    dplyr::select(-tot))


# Transform into final treemap format
treeplot_data <- purrr::map(base_data, function(dataset) {
  unique(dataset$habitat) %>%
    purrr::map(function(hab) {
      hab_data <- dataset %>%
        dplyr::filter(habitat == hab)
      list(
        name = hab,
        data = purrr::map(seq_len(nrow(hab_data)), function(i) {
          list(
            x = hab_data$gear[i],
            y = hab_data$value[i]
          )
        })
      )
    })
})

# Save the data
usethis::use_data(treeplot_data, overwrite = TRUE)
