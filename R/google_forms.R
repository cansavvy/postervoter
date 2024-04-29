#' Get Google Forms
#' @description This is a function to get the Google Forms API requests.
#' The scopes it uses are the `See all your Google Forms forms.` and `See all responses to your Google Forms forms.`
#' If you don't check this box on the OAuth screen this function won't work.
#' @param url The endpoint URL for the request
#' @param token credentials for access to Google using OAuth. `authorize("google")`
#' @param body_params The body parameters for the request
#' @param query_params The body parameters for the request
#' @param return_request Should a list of the request be returned as well?
#' @returns This function returns a list from a API response JSON file
#' @importFrom httr config accept_json content
#' @importFrom jsonlite fromJSON
#' @importFrom assertthat assert_that is.string
#' @export
request_google_forms <- function(token, url,
                                 body_params = NULL,
                                 query_params = NULL,
                                 return_request = TRUE) {
  if (is.null(token)) {
    # Get auth token
    token <- get_token(app_name = "google")
  }
  config <- httr::config(token = token)

  result <- httr::GET(
    url = url,
    body = body_params,
    query = query_params,
    config = config,
    httr::accept_json(),
    encode = "json"
  )

  request_info <- list(
    url = url,
    token = token,
    body_params = body_params,
    query_params = query_params
  )

  if (httr::status_code(result) != 200) {
    httr::stop_for_status(result)
    return(result)
  }

  # Process and return results
  result_content <- httr::content(result, "text")
  result_list <- jsonlite::fromJSON(result_content)

  if (return_request) {
    return(list(result = result_list, request_info = request_info))
  } else {
    return(result_list)
  }
}

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
#' form_info <- make_poll(new_name = "New Poster Poll")
#' }
make_poll <- function(new_name = "New Poster Poll", quiet = FALSE) {

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

  if (!quiet) {
    message(paste0("posterpoller form created at https://docs.google.com/forms/d/", result_list$id))
  }

  browseURL(paste0("https://docs.google.com/forms/d/", result_list$id))

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
#'
#' form_info <- make_poll(new_name = "New Poster Poll")
#'
#' # This has the id
#' form_info$id
#'
#' form_info <- get_google_form(form_info$id)
#'
#' ### OR You can give it a direct form id or URL
#'
#' form_info <- get_google_form("https://docs.google.com/forms/d/11xv81kvPTHISISFAKEPbilbpaC0s2HY8NO3js3Y/edit")
#'
#'
#' name="entry.
#' }
get_google_form <- function(form_id, token = NULL) {
  if (is.null(token)) {
    # Get auth token
    token <- get_token(app_name = "google")
  }
  # If a URL is supplied, only take the ID from it.
  if (grepl("https:", form_id[1])) {
    form_id <- gsub("\\/viewform$|\\/edit$", "", form_id)
    form_id <- gsub("https://docs.google.com/forms/d/e/|https://docs.google.com/forms/d/", "", form_id)
  }

  # Get auth token
  token <- get_token()
  config <- httr::config(token = token)

  tmp <- httr::GET("https://docs.google.com/forms/d/11xv81kvPYWxh66lHHsa1b4PbilbpaC0s2HY8NO3js3Y/prefill" ,
                   config = config)

  tmp

  form_info_url <- gsub("\\{formId\\}", form_id, "https://forms.googleapis.com/v1/forms/{formId}")
  form_response_url <- gsub("\\{formId\\}", form_id, "https://forms.googleapis.com/v1/forms/{formId}/responses")

  message(paste0("Trying to grab form: ", form_id))

  response_info <- request_google_forms(
    url = form_response_url,
    token = token,
    return_request = TRUE
  )

  result <- list(
    form_metadata = form_info,
    response_info = response_info
  )

  return(result)
}
