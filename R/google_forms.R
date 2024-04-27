
#' Setup posterpoller form
#' @param form_id The form_id that is desired to be copied.
#' @param new_name What should the new file name for the copied file be?
#' @param quiet TRUE or FALSE whether messages should be printed out.
#' @importFrom httr config accept_json content
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples \dontrun{
#' #'
#' # Make the form
#' form_info <- make_poll(form_id = "https://docs.google.com/forms/d/someformidhere/edit",
#'                        new_name = "copied form")
#' }
make_poll <- function(form_id, new_name = NULL, quiet = FALSE) {

    # Get endpoint url
  url <- "https://www.googleapis.com/drive/v3/files/1x2QwyztUMaL0mVFRN4Ds6fThnpJJ_z-FzLvfvHlbZ7M/copy"

  # Get auth token
  token <- get_token()
  config <- httr::config(token = token)

  # Wrapping body parameters in a requests list
  body_params <- list(
    "name" = new_name
  )

  # Modify course
  result <- httr::POST(url, config = config, body = body_params, query = list("supportsAllDrives" = TRUE), encode = "json")

  if (httr::status_code(result) != 200) {
    message("Cannot create form")
    return(result)
  }
  # Process and return results
  result_content <- content(result, "text")
  result_list <- fromJSON(result_content)

  if (quiet) {
    message(paste("posterpoller form created at", result_list$id))
  }

  return(result_list)
}


#' Get Poll Form Info
#' @description This is a function to get Google Form info and responses from the API.
#' The scopes it uses are the `See all your Google Forms forms.` and `See all responses to your Google Forms forms.`
#' If you don't check this box on the OAuth screen this function won't work.
#' @param form_id The form ID we need to get
#' @param token credentials for access to Google using OAuth. `authorize("google")`
#' @param dataformat What format would you like the data? Options are "raw" or "dataframe". "dataframe" is the default.
#' @returns This returns a list of the form info and responses to the google form. Default is to make this a list of nicely formatted dataframes.
#' @export
#' @examples \dontrun{
#'
#' authorize("google")
#' form_info <- get_google_form(
#'   "https://docs.google.com/forms/d/1Neyj7wwNpn8wC7NzQND8kQ30cnbbETSpT0lKhX7uaQY/edit"
#' )
#' form_id <- "https://docs.google.com/forms/d/1Neyj7wwNpn8wC7NzQND8kQ30cnbbETSpT0lKhX7uaQY/edit"
#'
#' ### OR You can give it a direct form id
#'
#' form_info <- get_google_form("1Neyj7wwNpn8wC7NzQND8kQ30cnbbETSpT0lKhX7uaQY")
#' }
get_google_form <- function(form_id, token = NULL, dataformat = "dataframe") {
  if (is.null(token)) {
    # Get auth token
    token <- get_token(app_name = "google")
  }
  # If a URL is supplied, only take the ID from it.
  if (grepl("https:", form_id[1])) {
    form_id <- gsub("\\/viewform$|\\/edit$", "", form_id)
    form_id <- gsub("https://docs.google.com/forms/d/e/|https://docs.google.com/forms/d/", "", form_id)
  }

  form_info_url <- gsub("\\{formId\\}", form_id, "https://forms.googleapis.com/v1/forms/{formId}")
  form_response_url <- gsub("\\{formId\\}", form_id, "https://forms.googleapis.com/v1/forms/{formId}/responses")

  message(paste0("Trying to grab form: ", form_id))

  form_info <- request_google_forms(
    url = form_info_url,
    token = token
  )

  response_info <- request_google_forms(
    url = form_response_url,
    token = token,
    return_request = TRUE
  )

  result <- list(
    form_metadata = form_info,
    response_info = response_info
  )

  if (dataformat == "dataframe") {
    metadata <- get_question_metadata(form_info)

    if (length(result$response_info$result) > 0) {
      answers_df <- extract_answers(result)
    } else {
      answers_df <- "no responses yet"
    }
    result <- list(
      title = result$form_metadata$result$info$title,
      metadata = metadata,
      answers = answers_df
    )
  }
  return(result)
}
