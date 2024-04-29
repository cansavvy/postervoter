
#' Make QR code for a poster
#' @description This returns a random jumble of letters and numbers that are used as poster ids
#' @param poster_id The associated id for the poster
#' @param poster_title The title for the poster
#' @param presenter_name The presenter of the poster
#' @returns This function returns a list from a API response JSON file
#' @export
#'
#'
make_qr_code <- function(prefill_url,
                         poster_id,
                         poster_title,
                         presenter_name,
                         dest_folder) {

  if (!dir.exists(dest_folder)) dir.create(dest_folder, showWarnings = FALSE)

  posters_url <- gsub("%7Bposter_id%7D", poster_id, prefill_url)

  #poster_title <- gsub(" ", "+", poster_title)
  #posters_url <- gsub("%7Bposter_title%7D", poster_title, posters_url)

  #presenter_name <- gsub(" ", "+", presenter_name)
  #posters_url <- gsub("%7Bpresenter_name%7D", presenter_name, posters_url)

  posters_url <- "https://docs.google.com/forms/d/e/1FAIpQLSeyLuU0f-2ow2kI62QWR4dIcr7hBib51yhnDThBvUNOL0z-RQ/viewform?usp=pp_url&entry.38519462=TDBTC3912B"
  api_endpoint <- paste0("https://api.qrserver.com/v1/create-qr-code/?data=", posters_url, "&size=150x150")

  response <- httr::GET(api_endpoint)

  png_file <- file.path(dest_folder, paste0(poster_id, "_", presenter_name, ".png"))

  download.file(api_endpoint,
                destfile = png_file
                )

  message("QR Code generated and stored as ", png_file)

  return(api_endpoint)
}
