#Shiny session 1

#first make sure we have the shiny package installed
install.packages("shiny")

#Shiny reference and documentation
#https://shiny.rstudio.com/reference/shiny/0.14/

#this session also references the how to start with R shiny webinar materials
#https://www.rstudio.com/resources/webinars/how-to-start-with-shiny-part-1/

#There is also a great library of example apps
#https://www.rstudio.com/products/shiny/shiny-user-showcase/

library(shiny)
#ui stands for user interface, this is what you w
ui <- fluidPage("Hello World")
#instructions for building the output that we see and instructions for your app to follow which are executed by the server (in our case our laptop), including what to display if the user 
server <- function(input, output) {}
#knits the two elements together into a shiny app
shinyApp(ui = ui, server = server)

#your r session is maintaining the app when we run it locally, once we close the app it goes dead.

#adding a sliderInput function to our app
sliderInput(inputId = "num",
            label = "Choose a number",
            value = 25, min = 1, max = 100)
#if we run at command line.
#html associated with some css classes
#we can add to our earlier app.
#each input function has additional arguments to help control this, these are specific to the different types of input.

#add a graph
#you can put as many rows as you want within the brackets so can add more complex content
output$hist <- renderPlot({
  title <- "100 random normal values"
  hist(rnorm(100), main = title)
})

#we can make this plot dependant upon the input
output$hist <- renderPlot({
  hist(rnorm(input$num), main = title)
})

#put this together into an app
ui <- fluidPage(
  sliderInput(inputId = "num",
              label = "Choose a number",
              value = 25, min = 1, max = 100),
  plotOutput("hist")
)

server <- function(input, output) {
  output$hist <- renderPlot({
    hist(rnorm(input$num))
  })
}

shinyApp(ui = ui, server = server)

