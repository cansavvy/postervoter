library(tidyverse)
library(flexdashboard)
library(gsheet)
library(magrittr)
library(shiny)
library(googlesheets4)
library(googledrive)

# Datasets ----


# UI ----
ui <- fluidPage(
  uiOutput("page")
)


# Server ----
server <- function(input, output) {
  output$poster_info <- eventReactive(input$go, {
    get_poster_id()
  })

  output$page <- reactive({
    if (class(try(output$poster_info, silent = TRUE)) != "try-error" ) {
      renderUI({
        h2("Poster Info:")
        p("Does this info match the poster you wish to vote on? \n")
        p("Presenter:", output$poster_info$presenter_name, "\n")
        p("Title:", output$poster_info$poster_title, "\n")
        selectInput(
          "ranking", "Choose a ranking for this poster:",
          list(`Ranking` = list("First", "Second", "Third"))
        )
        actionButton("submit", "Submit", icon("fas fa-sync"))
      })
    }
  })
}

authenticate <- function() {
  # designate project-specific cache
  options(gargle_oauth_cache = ".secrets")

  # check the value of the option, if you like
  gargle::gargle_oauth_cache()

  if (interactive()) {
    googlesheets4::gs4_deauth()
    googlesheets4::gs4_auth(
      email = "cansav09@gmail.com",
      path = NULL,
      scopes = c("https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive"),
      # Get new token if it doesn't exist
      cache = ".secrets/",
      use_oob = FALSE,
      token = NULL
    )
  } else {
    googlesheets4::gs4_deauth()
    googlesheets4::gs4_auth(
      email = "cansav09@gmail.com",
      scopes = c("https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive"),
      cache = ".secrets/"
    )
  }
}

get_poster_id <- function(poster_id = "AMYAM4850U") {
  poster_sheet <- "https://docs.google.com/spreadsheets/d/12aomFyT0zEHNmpyCQoGdDh16P-bRp4Pkt4PCCrU7gYY/edit"
  authenticate()

  poster_key <- googlesheets4::read_sheet(
    poster_sheet,
    sheet = "posterpoller_id_key"
  )

  # Get URL query
  query <- parseQueryString(session$clientData$url_search)
  print(query)
  # if (is.null(query[["poster_id"]])) query[["poster_id"]] <- NA

  # poster_id <- query[["poster_id"]]

  poster_info <- poster_key %>%
    dplyr::filter(poster_id == poster_id)

  return(poster_info)
}

shinyApp(ui, server)
