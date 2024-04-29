### Declare all the scopes
scopes_list <- c(
  "https://www.googleapis.com/auth/spreadsheets",
  "https://www.googleapis.com/auth/spreadsheets.readonly",
  'https://www.googleapis.com/auth/drive.file',
  'https://www.googleapis.com/auth/drive',
  'https://www.googleapis.com/auth/drive.file',
  'https://www.googleapis.com/auth/drive.metadata'
)


#' Authorize R package to access endpoints
#' @description This is a function to authorize the R package to access APIs interactively. To learn more about the privacy policy for posterpoller [read here](https://www.metricminer.org/privacypolicy.html)
#' @param app_name app would you like to authorize? Supported apps are 'google' 'calendly' and 'github'
#' @param cache Should the token be cached as an .httr-oauth file or API keys stored as global options?
#' @param ... Additional arguments to send to \code{\link{oauth2.0_token}}
#' @return API token saved to the environment or the cache so it can be grabbed by functions
#' @importFrom utils menu installed.packages browseURL
#' @importFrom httr oauth_app oauth_endpoints oauth2.0_token
#' @importFrom stringr str_to_title
#' @export
#' @examples \dontrun{
#'
#' authorize()
#'
#' }
authorize <- function(app_name = "google",
                      cache = FALSE,
                      ...) {

  # Check if token already exists
  token_status <- check_for_tokens(app_name)

  if (any(token_status)) {
    message(paste0("Credentials found for ", paste0(stringr::str_to_title(names(token_status)[token_status]), collapse = ", ")))
    message("Do you want to overwrite these with new credentials?")
    use_old <- menu(c("Yes, overwrite the credentials", "No, I'll use these credentials and stop this function."))
    if (use_old == 2) stop("Using old credentials")
  }

  if (!cache) {
    message("Would you like to store/cache your credentials?")
    cache_it <- menu(c("Yes cache/store credentials", "No do not store credentials, I will re-run this authorize() in my next R session"))
    if (cache_it == 1) {
      message("You chose to cache your credentials, if you change your mind, run posterpoller::delete_creds(). \nBe careful not to push the cache files to GitHub or share it anywhere. \n")
    }
  } else {
    cache_it <- 1
  }

  if (app_name == "google") {

    token <- httr::oauth2.0_token(
      endpoint = app_set_up(app_name)$endpoint,
      app = app_set_up(app_name)$app,
      scope = scopes_list,
      cache = cache_it == 1)

    googledrive::drive_auth(token = token)
    googlesheets4::gs4_auth(token = token)

    # If they chose to cache it, we'll store it in rds file format
    if (cache_it == 1) cache_token(token, "google")
  }
  set_token(token = token, app_name = app_name)

  invisible(token)
}

################################################################################
#' Delete cached posterpoller credentials
#' @description This is a function to delete cached creds and creds in the current environment that were set by posterpoller
#' @param app_name which app would you like to delete the creds for? Default is to delete the creds for all.
#' @export
#' @return Cached credentials are deleted and report is given back
#' @examples \dontrun{
#'
#' delete_creds("google")
#' }
delete_creds <- function(app_name = "google") {
  supported <- "google"

  if (!(app_name %in% c("all", supported))) stop("That is not a supported app or endpoint")

  ## Checking for the existence of cached creds
  google_creds_exist <- !is.null(getOption("google"))
  google_cache_exist <- file.exists(file.path(cache_secrets_folder(), "google.RDS"))

  # Do any exist?
  none_exist <- all(!google_creds_exist,!google_cache_exist)

  if (none_exist) {
    message("No cached creds to delete (from posterpoller anyway). Done")
  } else {
    if (app_name == "all" | app_name == "google") {
      if (google_creds_exist) {
        remove_token("google")
        message("Cached Google token removed from environment")
      }
      if (google_cache_exist) {
        remove_cache("google")
        message("Cached Google creds removed from cache")
      }
    }
  }
}

#' Use secrets to Authorize R package to access endpoints
#' @description This is a function to authorize posterpoller to access calendly, github or google noninteractively from passing in a keys or tokens.
#' @param app_name Which app are you trying to authorize? 'google', 'calendly' or 'github'?
#' @param token For calendly or github, pass in the API key or Personal Access Token that you have set up from going to https://github.com/settings/tokens/new or https://calendly.com/integrations/api_webhooks respectively.
#' @param cache Should the credentials be cached? TRUE or FALSE?
#' @param access_token For Google, access token can be obtained from running authorize interactively: token <-authorize(); token$credentials$access_token
#' @param refresh_token For Google, refresh token can be obtained from running authorize interactively: token <-authorize(); token$credentials$refresh_token
#' @param in_test If setting up auth in a test, set to TRUE so that way the authorization doesn't stick
#' @return OAuth token saved to the environment so the package access the API data
#' @importFrom utils menu installed.packages
#' @importFrom httr oauth_app oauth_endpoints oauth2.0_token
#' @export
#' @examples \dontrun{
#'
#' # Example for authorizing Calendly
#' # You go to https://calendly.com/integrations/api_webhooks to get an api key
#' auth_from_secret("calendly", token = "A_calendly_token_here")
#'
#' # Example for GitHub
#' # You go to https://github.com/settings/tokens/new to get a Personal Access Token
#' auth_from_secret("github", token = "ghp_a_github_pat_here")
#'
#' # Example for authorizing for Google
#' token <- authorize("google")
#' auth_from_secret(
#'   app_name = "google",
#'   access_token = token$credentials$access_token,
#'   refresh_token = token$credentials$refresh_token
#' )
#' }
#'
auth_from_secret <- function(app_name = "google", token, access_token, refresh_token, cache = FALSE,
                             in_test = FALSE) {

  if (app_name == "google") {
    if (is.null(access_token) || is.null(refresh_token)) {
      stop("For Google auth, need access_token and refresh_token cannot be NULL")
    }

    credentials <- list(
      access_token = access_token,
      expires_in = 3599L,
      refresh_token = refresh_token,
      scope = scopes_list,
      token_type = "Bearer"
    )

    token <- httr::oauth2.0_token(
      endpoint = app_set_up(app_name)$endpoint,
      app = app_set_up(app_name)$app,
      cache = cache,
      scope = scopes_list,
      credentials = credentials
    )
    googledrive::drive_auth(token = token)
    googlesheets4::gs4_auth(token = token)
  }

  if (cache) {
    message("You chose to cache your credentials, if you change your mind, run posterpoller::delete_creds().
            \n Be careful not to push .httr-oauth or RDS files to GitHub or share it anywhere.")
    cache_token(token, app_name = app_name)
  }
  # Store the token in the environment
  set_token(app_name = app_name, token, in_test = in_test)

  invisible(token)
}

#' App Set Up
#' @description This is a function that sets up the app. It's generally called by another function
#' @param app_name app would you like to authorize? Supported apps are 'google' 'calendly' and 'github'
#' @importFrom utils menu installed.packages
#' @importFrom httr oauth_app oauth_endpoints oauth2.0_token
#'
# This sets up the app creds no matter which way authorization is called
app_set_up <- function(app_name = "google") {
  decrypted <- openssl::aes_cbc_decrypt(
    readRDS(encrypt_creds_path("google")),
    key = readRDS(key_encrypt_creds_path())
  )

  app <- httr::oauth_app(
    appname = "posterpoller",
    key = unserialize(decrypted)$client_id,
    secret = unserialize(decrypted)$client_secret
  )

  endpoint_url <- httr::oauth_endpoints("google")

  return(list(app = app, endpoint = endpoint_url))
}

