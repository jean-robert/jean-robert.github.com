shinyUI(bootstrapPage(
  
  selectInput(inputId = "friend1",
              label = "Number of bins in histogram (approximate):",
              choices = c(T, F),
              selected = F),
  
))