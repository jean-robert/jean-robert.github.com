require(shiny)
source("ratp.R")
source("ratp.plot.R")
source("dijkstra.R")

shinyServer(function(input, output) {

  # retrieve the plot from plotting functions in ratp.plot
  output$main_plot <- renderPlot({
    # max 5 friends...
    friends <- unique(c(input$friend1, input$friend2, input$friend3, input$friend4, input$friend5))
    friends <- friends[friends!="N/A"]
    if(length(friends)>1) {
      friends <- as.character(getIDFromStation(friends))
      p <- plotPath(plotBase(T), friends)
    } else {
      p <- plotBase(F)
    }
    print(p)
  })

  # retrieve station to output as text
  output$suggestions_text <- renderPrint({

    friends <- unique(c(input$friend1, input$friend2, input$friend3, input$friend4, input$friend5))
    friends <- friends[friends!="N/A"]
    if(length(friends)>1) {
      friends <- as.character(getIDFromStation(friends))
      target <- findTarget(friends, "minmax")
      ans <- paste("You should meet at", getStationFromID(target))
    } else {
      ans <- "Pick the stations you leave from"
    }
    cat(ans)
  })
})
