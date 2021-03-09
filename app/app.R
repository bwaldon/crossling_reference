library(tidyverse)
library(shiny)
library(shinyjs)
library(rsconnect)
library(shinydashboard)

rm(list = ls())

# options("repos" = c("CRAN" = "https://cran.rstudio.com",
#                     "svn.r-project" = "https://svn.r-project.org/R-packages/trunk/foreign"))

# library(rsconnect)
# rsconnect::deployApp()

rsconnect::setAccountInfo(name='bwaldon',
                          token='2B9F9F6D91C01491BF65FF16284A4ADE',
                          secret='mXLXwxo15TntdN5s8vwyyjB4+FKUXAiH/5bqtimv')

# LOAD MODEL

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

colorOvermodification <- read_csv("colorOvermodification.csv") %>%
  mutate(type = "color")
sizeOvermodification <- read_csv("sizeOvermodification.csv") %>%
  mutate(type = "size")

df <- colorOvermodification %>%
  bind_rows(sizeOvermodification)

rm(colorOvermodification, sizeOvermodification)

base = 8
expand = 4

ggplot(df %>% filter(colorNoise == 0.6, sizeNoise == 0.5, alpha == 5), aes(x = language, y = speakerProb, fill = type)) +
  theme_bw() +
  geom_bar(stat="identity",position = "dodge") +
  xlab("Language/idiolect") +
  ylab("Probability of\nredundant modification") +
  labs(fill = "Overmodification type") +
  theme(legend.position = "bottom",
        text = element_text(size = base * expand / 2, face = "bold"))

# Define the UI
ui <- dashboardPage(skin = "blue",
  dashboardHeader(titleWidth = 600, title = "Exploring the model from Waldon and Degen (2021)"),
  dashboardSidebar(sidebarMenu(sliderInput("colorNoise", "Semantic value of color:",
                               min = 0.5, max = 1, value = 1, step = 0.1),
                   sliderInput("sizeNoise", "Semantic value of size:",
                               min = 0.5, max = 1, value = 1, step = 0.1),
                   shinyWidgets::sliderTextInput("alpha","Alpha:" , 
                                                 choices = c(1,2.5,5,10,15,20),
                                                 selected = 5,),
                   actionButton("show", "Show utterance alternatives"))),
  dashboardBody(fluidRow(align='center',"Check out the paper at https://scholarworks.umass.edu/scil/vol4/iss1/20/"),
  fluidRow(style = "padding:5px", align = "center", plotOutput('plot')),
  # fluidRow(align = "center", img(src = "tablev2.png", width = 800)),
  )
)

# Define the server code
server <- function(input, output) {
  output$plot <- renderPlot({
    # req(input$alpha)
    ggplot(df %>% filter(colorNoise == input$colorNoise, sizeNoise == input$sizeNoise, alpha == input$alpha), aes(x = language, y = speakerProb, fill = type)) +
      theme_bw() +
      scale_fill_manual(values=c("#4287f5","#fff200")) +
      geom_bar(stat="identity",position = "dodge") +
      xlab("Language/idiolect") +
      ylab("Probability of\nredundant modification") +
      labs(fill = "Redundant modification type") +
      theme(legend.position = "top",
            text = element_text(size = base * expand / 2, face = "bold")) +
      ylim(0, 1)
  })
  observeEvent(input$show, {
    showModal(modalDialog(
      title = "Utterance alternatives",
      HTML('<img src="tablev2.png" width="550" >'),
      size="l",
      fade=F,
      easyClose = TRUE
    ))
  })
}

# Return a Shiny app object
shinyApp(ui = ui, server = server)
  
