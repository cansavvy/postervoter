library(metricminer)
library(shinysurveys)
library(shiny)

df <- data.frame(
  question = "",
  option = 1:10,
  input_type = "select",
  input_id = "rating",
  dependence = NA,
  dependence_value = NA,
  required = T
)

ui <- fluidPage(
  surveyOutput(
    df = df,
    survey_title = "",
    survey_description = "On a scale of 1 - 10, how likely would you be to recommend this course?"
  )
)

server <- function(input, output, session) {
  renderSurvey()

  observeEvent(input$submit, {
    showModal(modalDialog(
      title = "Thank you for your feedback!"
    ))

    response_data <- data.frame(getSurveyData())
    print(response_data)
    str(response_data)

    googlesheets4::sheet_append(
      data = response_data,
      ss = "https://docs.google.com/spreadsheets/d/1EZvP4nf0XBYQ2I1aBBF9ljoZpTtLds_JcOJqPfDIcYE/edit#gid=0"
    )
  })
}
