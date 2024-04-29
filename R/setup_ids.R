
#' Make a random id
#' @description This returns a random jumble of letters and numbers that are used as poster ids
#' @param n How many ids do you want returned?
#' @param seed Set a seed so that the IDs will be the same if you rerun this
#' @returns A vector of length n with that many random ids
#' @export
#'
make_random_ids <- function(n = 1, seed = 1234) {
  set.seed(seed)
  a <- do.call(paste0, replicate(5, sample(LETTERS, n, TRUE), FALSE))
  paste0(a, sprintf("%04d", sample(9999, n, TRUE)), sample(LETTERS, n, TRUE))
}

#' Generate poster ids
#' @description Given a poster googlesheet with the columns `poster_title` and `presenter_name` this function will create a new sheet that has a column with unique poster ids
#' @param prefill_url Go to your form, click on the vertical "..." to see more options in the right corner. Click "get prefill link".
#' Put in the poster id and poster name responses {poster_id} and {poster_name} respectively
#' @param poster_googlesheet A link to a googlesheet that contains at least two column names that are `poster_title` and `presenter_name`
#' @returns A folder of QR code PNGs, a data frame with the information, and googlesheets that has the links to those QR_codes and poster ids
#' @importFrom googlesheets4 sheet_write sheet_properties
#' @importFrom purrr pmap
#' @importFrom dplyr filter pull
#' @importFrom magrittr %>%
#' @importFrom googledrive as_id
#' @export
#' @examples \dontrun{
#'
#' prefill_url <- "https://docs.google.com/forms/d/e/1FAIpQLSepdIqUoLA9fgPksF_x7r5-hvTbd8ZoDH2h0uUQuvVdvhujMA/viewform?usp=pp_url&entry.38519462=%7Bposter_id%7D&entry.1154882998=%7Bposter_name%7D"
#' poster_googlesheet <- "https://docs.google.com/spreadsheets/d/12aomFyT0zEHNmpyCQoGdDh16P-bRp4Pkt4PCCrU7gYY/edit#gid=0"
#'
#'generate_poster_ids(prefill_url = prefill_url,
#'                    poster_googlesheet = poster_googlesheet)
#'
#'}

generate_poster_ids <- function(prefill_url, poster_googlesheet, dest_folder = "qr_codes") {

  library(magrittr)

  poster_key <- googlesheets4::read_sheet(
    poster_googlesheet
  )

  num_of_posters <- nrow(poster_key)

  poster_key$poster_id <- make_random_ids(num_of_posters)
  poster_key$prefill_url <- prefill_url
  poster_key$dest_folder <- dest_folder

  sheet_url <- googlesheets4::sheet_write(
    as.data.frame(poster_key),
    ss = poster_googlesheet,
    sheet = "posterpoller_id_key"
  )

  qr_code_links <- purrr::pmap(poster_key, function(prefill_url, poster_id, presenter_name, poster_title, dest_folder) {

    qr_link <- make_qr_code(prefill_url = prefill_url,
                 poster_id = poster_id,
                 poster_title = poster_title,
                 presenter_name = presenter_name,
                 dest_folder = dest_folder
                 )

    return(qr_link)
  })

  qr_code_links

  poster_data <- data.frame(poster_key,
                            qr_link = unlist(purrr::map(qr_code_links, ~ .x$url)),
                            file_paths = unlist(purrr::map(qr_code_links, ~ .x$file_path)))

  sheet_url <- googlesheets4::sheet_write(
    poster_data,
    ss = poster_googlesheet,
    sheet = "posterpoller_id_key"
  )

  purrr::pmap(poster_data %>% dplyr::select(presenter_name, file_paths),
              function(presenter_name, file_paths){
    add_presenter_name(presenter_name = presenter_name,
                       png = file_paths)

  })

  base_url <- "https://docs.google.com/spreadsheets/d/"

  sheet_id <-  googlesheets4::sheet_properties(sheet_url) %>%
    dplyr::filter(name == "posterpoller_id_key") %>%
    dplyr::pull(id)

  url <-paste0(
    base_url,
    googledrive::as_id(sheet_url),
    "/edit#gid=",
    sheet_id)

  message("Data saved in ", url)

  browseURL(url)

  return(poster_data)
}
