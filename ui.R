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
