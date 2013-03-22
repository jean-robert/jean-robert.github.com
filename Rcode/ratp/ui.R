shinyUI(bootstrapPage(
  
  headerPanel("Metro Meeting Point"),
  
  sidebarPanel(
     selectInput(inputId = "friend1",
                 label = "Station 1 :",
                 choices = c("N/A", sort(u.stations.name.enc)),
                 selected = "N/A"),
     selectInput(inputId = "friend2",
                 label = "Station 2 :",
                 choices = c("N/A", sort(u.stations.name.enc)),
                 selected = "N/A"),
     # conditional inputs, allowing 5 friends at most
     conditionalPanel(condition = "input.friend2 != 'N/A'",
                      selectInput(inputId = "friend3",
                                  label = "Station 3 :",
                                  choices = c("N/A", sort(u.stations.name.enc)),
                                  selected = "N/A")
     ),
     conditionalPanel(condition = "input.friend3 != 'N/A'",
                      selectInput(inputId = "friend4",
                                  label = "Station 4 :",
                                  choices = c("N/A", sort(u.stations.name.enc)),
                                  selected = "N/A")
     ),
     conditionalPanel(condition = "input.friend4 != 'N/A'",
                      selectInput(inputId = "friend5",
                                  label = "Station 5 :",
                                  choices = c("N/A", sort(u.stations.name.enc)),
                                  selected = "N/A")
     )
  ),
  
  mainPanel(
    h3(textOutput(outputId = "suggestions_text")),
    
    plotOutput(outputId = "main_plot", height="500px")
    )
    
))