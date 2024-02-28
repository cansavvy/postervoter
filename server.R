library(metricminer)

server <- function(input, output, session) {
  renderSurvey()

  observeEvent(input$submit, {
    showModal(modalDialog(
      title = "Thank you for your feedback!"
    ))

    response_data <- data.frame(getSurveyData())
    print(response_data)
    str(responses)

    googlesheets4::sheet_append(
      response_data,
      "https://docs.google.com/spreadsheets/d/1EZvP4nf0XBYQ2I1aBBF9ljoZpTtLds_JcOJqPfDIcYE/edit#gid=0"
    )
  })
}
