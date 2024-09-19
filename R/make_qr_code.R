
#' Make QR code for a poster
#' @description This returns a random jumble of letters and numbers that are used as poster ids
#' @param prefill_url Go to your form, click on the vertical "..." to see more options in the right corner. Click "get prefill link".
#' Put in the poster id and poster name responses `\{poster_id\}` and `\{poster_name\}` respectively
#' @param dest_folder A character string of the folder where qr-codes should be saved. If the folder doesn't exist, one will be made with this name. Default is `qr-codes`.
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

  posters_url <- gsub("%7Bposter_id%7D", as.character(poster_id), prefill_url)

  posters_url <- gsub("%7Bpresenter_name%7D", presenter_name, posters_url)

  posters_url <- gsub("%7Bposter_title%7D", poster_title, posters_url)

  api_endpoint <- paste0("https://api.qrserver.com/v1/create-qr-code/?data=", URLencode(posters_url), "&size=200x200")

  response <- httr::GET(api_endpoint)

  png_file <- file.path(dest_folder, paste0(poster_id, "_", gsub(" ", "_", presenter_name), ".png"))

  download.file(api_endpoint,
                destfile = png_file
                )

  add_presenter_name(presenter_name = presenter_name,
                     png = png_file,
                     poster_id = as.character(poster_id))

  message("QR Code generated and stored as ", png_file)

  return(list(url = api_endpoint, file_path = png_file))
}
