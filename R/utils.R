
requireNamespace("magrittr")

utils::globalVariables(c(
"URLencode",  "browseURL", "download.file", "id", "name", "poster_googlesheet",
"poster_title", "presenter_name"))

#' Poster Data Example File
#' Get file path to an example poster data file
#' @export
#' @return Returns the file path to folder where the example data is stored
example_poster_data_file_path <- function() {
  file <- list.files(
    pattern = "fake_poster_data.csv",
    recursive = TRUE,
    system.file("extdata", package = "posterpoller"),
    full.names = TRUE
  )
  file
}
