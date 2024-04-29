
#' Make QR code for a poster
#' @description This returns a random jumble of letters and numbers that are used as poster ids
#' @param n How many ids do you want returned?
#' @returns This function returns a list from a API response JSON file
#' @export
#'
make_qr_code <- function(prefill_url,
                         poster_id,
                         poster_name,
                         dest_folder = "qr_codes") {

  if (!dir.exists(dest_folder)) dir.create(dest_folder, showWarnings = FALSE)

  posters_url <- gsub("%7Bposter_id%7D", poster_id, prefill_url)

  poster_name <- gsub(" ", "+", poster_name)
  posters_url <- gsub("%7Bposter_name%7D", poster_name, posters_url)

  api_endpoint <- paste0("https://api.qrserver.com/v1/create-qr-code/?data=\'", posters_url, "\'&size=150x150")

  response <- httr::GET(api_endpoint)

  png_file <- file.path(dest_folder, paste0(poster_id, "_", presenter_name, ".png"))

  download.file(api_endpoint,
                destfile = png_file
                )

  message("QR Code generated and stored as ", png_file)

  return(api_endpoint)
}
