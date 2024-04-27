
make_random_ids <- function(n = 1) {
  a <- do.call(paste0, replicate(5, sample(LETTERS, n, TRUE), FALSE))
  paste0(a, sprintf("%04d", sample(9999, n, TRUE)), sample(LETTERS, n, TRUE))
}


generate_poster_ids <- function(poster_googlesheet) {

  auth()

  poster_key <- googlesheets4::read_sheet(
    poster_googlesheet
  )

  num_of_posters <- nrow(poster_key)

  poster_key$poster_id <- make_random_ids(num_of_posters)

  sheet_url <- googlesheets4::sheet_write(
    as.data.frame(poster_key),
    ss = poster_googlesheet,
    sheet = "posterpoller_id_key"
  )

  purrr::pmap(
    dplyr::select(poster_key, poster_id, presenter_name), function(poster_id, presenter_name) {

    make_qr_code(poster_id = poster_id,
                 presenter_name = presenter_name,
                 app_url = "test/")

  })


  base_url <- "https://docs.google.com/spreadsheets/d/"

  sheet_id <- sheet_properties(sheet_url) %>%
    dplyr::filter(name == "posterpoller_id_key") %>%
    dplyr::pull(id)

  url <-paste0(
    base_url,
    as_id(sheet_url),
    "/edit#gid=",
    sheet_id)




  return(as_id(sheet_url))
}
