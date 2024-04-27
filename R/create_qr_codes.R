

get_response_ids <- function() {



}


make_qr_code <- function(poster_id,
                         presenter_name,
                         google_form,
                         dest_folder = "qr_codes") {

  if (!dir.exists(dest_folder)) dir.create(dest_folder, showWarnings = FALSE)

  posters_url <- paste0(app_url, "?poster_id=", poster_id)

  api_endpoint <- paste0("https://api.qrserver.com/v1/create-qr-code/?data=\'", posters_url, "\'&size=150x150")

  response <- httr::GET(api_endpoint)

  png_file <- file.path(dest_folder, paste0(poster_id, "_", presenter_name, ".png"))

  download.file(api_endpoint,
                destfile = png_file
                )

  message("QR Code generated and stored as ", png_file)

  return(api_endpoint)
}
