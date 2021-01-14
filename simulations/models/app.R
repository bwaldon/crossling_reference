library(tidyverse)
library(shiny)
library(shinyjs)
library(cowplot)
library(rsconnect)
library(jsonlite)

# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# options("repos" = c("CRAN" = "https://cran.rstudio.com",
#                     "svn.r-project" = "https://svn.r-project.org/R-packages/trunk/foreign"))

# library(rsconnect)
# rsconnect::deployApp()

# LOAD MODEL

source("wpplfunctions.R")
wordsAndCosts <- read_file("pins/wordsAndCosts.txt")
meanings <- read_file("pins/meanings.txt")
speakermodels <- read_file("speakermodels.txt")

runWebPPL <- runWebPPL_nonlocal

base = 6
expand = 4

asymGraph <- function(probArray) {
  
  toGraph <- data.frame(matrix(NA, nrow = 4, ncol = 3))
  colnames(toGraph) <- c("language", "behavior", "probability")
  toGraph$language <- c("English", "English", "Arabic", "Arabic")
  toGraph$behavior <- c("Color over-mod\n('small blue'):", "Size over-mod\n('big red'):", 
                        "Color over-mod\n('small blue'):", "Size over-mod\n('big red'):")
                        # "Color over-mod\n('small blue'):", "Size over-mod\n('big red'):")
  toGraph$probability <- probArray
  
  p <- ggplot(toGraph, aes(x=behavior, y=probability, fill = language)) +
    theme_bw() +
    theme(text = element_text(size = base * expand / 2, face = "bold")) +
    xlab(element_blank()) +
    ylab("Probability of behavior") +
    geom_bar(stat="identity",position = "dodge") +
    # for hypothetical graphs
    theme(legend.title = element_blank(), legend.position="top", axis.text.x = element_blank())
  
  imglabels <- plot_grid(NULL, smallbluelabel, NULL, bigredlabel, nrow = 1, scale = 0.8, rel_widths = c(0 ,1,-0.1,1)) + 
    theme(plot.margin = unit(c(0, 0, 0, 0), "cm"))
  
  graph <- plot_grid(p,imglabels, nrow = 2, align = "hv", rel_heights = c(3,1))
  
  return(graph)
}

smallbluelabel <- ggdraw() + draw_image("app_images/psmallblue.png")
bigredlabel <- ggdraw() + draw_image("app_images/pbigred.png") 
vRSA_label <- ggdraw() + draw_image("app_images/vRSA_label.png")
incRSA_label <- ggdraw() + draw_image("app_images/incRSA_label.png")
cRSA_label <- ggdraw() + draw_image("app_images/cRSA_label.png")
inccRSA_label <- ggdraw() + draw_image("app_images/inccRSA_label.png")

# VANILLA RSA COMMANDS

vRSA <- '
var v1 = Math.exp(globalUtteranceSpeaker("smallblue", states, utterancesEnglish).score("START small blue pin STOP")) 
var v2 = Math.exp(globalUtteranceSpeaker("bigred", states, utterancesEnglish).score("START big red pin STOP")) 
var v3 = Math.exp(globalUtteranceSpeaker("smallblue", states, utterancesArabic).score("START pin blue small STOP")) 
var v4 = Math.exp(globalUtteranceSpeaker("bigred", states, utterancesArabic).score("START pin red big STOP")) 
// var v5 = Math.exp(globalUtteranceSpeaker("smallblue", states, utterancesSpanish).score("START small pin blue STOP")) 
// var v6 = Math.exp(globalUtteranceSpeaker("bigred", states, utterancesSpanish).score("START big pin red STOP")) 
JSON.stringify([v1,v2,v3,v4])'

incRSA <- '
var v1 = incrementalUtteranceSpeaker("START small blue pin STOP", "smallblue", states, utterancesEnglish)
var v2 = incrementalUtteranceSpeaker("START big red pin STOP", "bigred", states, utterancesEnglish)
var v3 = incrementalUtteranceSpeaker("START pin blue small STOP", "smallblue", states, utterancesArabic)
var v4 = incrementalUtteranceSpeaker("START pin red big STOP", "bigred", states, utterancesArabic)
// var v5 = incrementalUtteranceSpeaker("START small pin blue STOP", "smallblue", states, utterancesSpanish)
// var v6 = incrementalUtteranceSpeaker("START big pin red STOP", "bigred", states, utterancesSpanish)
JSON.stringify([v1,v2,v3,v4])'

# m <- read_file("m.txt")
# runWebPPL_nonlocal(m, vRSA, 1, 1, 1)
# runWebPPL(m, vRSA, 1, 1, 1)

ui <- fluidPage(
  
  tags$script(src = "http://cdn.webppl.org/webppl-v0.9.15.js"),
  tags$script(src = "http://webppl.org/homepage.js"),
  
  # App title ----
  titlePanel("Comparing speaker production models"),

  fluidRow(
    column(12, align="center",
           imageOutput("sceneimg", inline = TRUE),
    )
  ),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      selectInput("scene", "Scene type:",
                  c("bigblue, bigred, smallblue" = "bb_br_sb",
                    "bigred, smallblue" = "br_sb",
                    "smallred, bigred, smallblue" = "sr_br_sb"
                ),
                  selected = "bb_br_sb"),
      
      numericInput(inputId = "alpha",
                  label = "Alpha:",
                  value = 4,
                  min = 1,
                  max = 100),
      
      numericInput(inputId = "colorcost",
                   label = "Color word cost:",
                   value = 1,
                   step = 0.1,
                   min = 0,
                   max = 2),
      
      numericInput(inputId = "sizecost",
                   label = "Size word cost:",
                   value = 1,
                   step = 0.1,
                   min = 0,
                   max = 2),
      
      numericInput(inputId = "nouncost",
                   label = "Noun (pin) cost:",
                   value = 0,
                   step = 0.1,
                   min = 0,
                   max = 2),
      
      numericInput(inputId = "sizenoise",
                   label = "Semantic value of size*:",
                   value = 0.8,
                   step = 0.1,
                   min = 0,
                   max = 1),
      
      numericInput(inputId = "colornoise",
                   label = "Semantic value of color*:",
                   value = 0.99,
                   step = 0.1,
                   min = 0,
                   max = 1),
      
    # actionButton("go", "Update params"),
     #  
     # br(), br(),
      
      "*continuous models only.",
      
    width=3),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      fluidRow(
        column(3, checkboxInput("vGraph", "Vanilla RSA", value = TRUE, width = NULL)),
        column(3, checkboxInput("incGraph", "Incremental RSA", value = FALSE, width = NULL)),
        column(3, checkboxInput("cGraph", "Continuous RSA", value = FALSE, width = NULL)),
        column(3,checkboxInput("inccGraph", "Incremental-continuous RSA", value = FALSE, width = NULL))),
      
      # Output: Plot ----
   
      plotOutput("plots")
      
    )
  )
  
)

server <- function(input, output, session) {
  
  model <- reactive({
    if(input$scene == "bb_br_sb") {
      states = 'var states = ["bigblue", "bigred", "smallblue"] \n'
      utterances <- read_file("pins/utterances_bb_br_sb.txt")
    } else if (input$scene == "br_sb") {
      states = 'var states = ["bigred", "smallblue"] \n'
      utterances <- read_file("pins/utterances_br_sb.txt")
    } else if (input$scene == "sr_br_sb") {
      states = 'var states = ["smallred", "bigred", "smallblue"] \n'
      utterances <- read_file("pins/utterances_sr_br_sb.txt")
    }
    paste(states, meanings, wordsAndCosts, utterances, speakermodels, sep = "\n")
  })

  
  output$plots <- renderPlot({

    if(input$vGraph) {

      vrsa_data = fromJSON(runWebPPL(model(), vRSA, input$alpha, colorNoise =  1, sizeNoise = 1, sizeCost = input$sizecost,
                           colorCost =  input$colorcost, nounCost =  input$nouncost))

      graph1 <<- asymGraph(vrsa_data)

    } else {

      graph1 <<- NULL

    }

    if(input$incGraph) {

      incrsa_data <-fromJSON(runWebPPL(model(), incRSA, input$alpha, colorNoise =  1, sizeNoise = 1, sizeCost = input$sizecost,
                           colorCost =  input$colorcost, nounCost =  input$nouncost))

      graph2 <<- asymGraph(incrsa_data)

    } else {

      graph2 <<- NULL

    }

    if(input$cGraph) {

      crsa_data = fromJSON(runWebPPL(model(), vRSA, input$alpha, colorNoise = input$colornoise, sizeNoise = input$sizenoise, sizeCost = input$sizecost,
                           colorCost =  input$colorcost, nounCost =  input$nouncost))

      graph3 <<- asymGraph(crsa_data)

    } else {

      graph3 <<- NULL

    }

    if(input$inccGraph) {

      inccrsa_data = fromJSON(runWebPPL(model(), incRSA, input$alpha, colorNoise = input$colornoise, sizeNoise = input$sizenoise, sizeCost = input$sizecost,
                           colorCost =  input$colorcost, nounCost =  input$nouncost))

      graph4 <<- asymGraph(inccrsa_data)

    } else {

      graph4 <<- NULL

    }
    
    plot_grid(vRSA_label, incRSA_label, graph1, graph2, cRSA_label, inccRSA_label, graph3, graph4,
              nrow = 4, rel_heights = c(1,8))

  })
  
  
  output$sceneimg <- renderImage({
    if(input$scene == "bb_br_sb") {
      filename <- "www/bb_br_sb.png"
    } else if (input$scene == "br_sb") {
      filename <- "www/br_sb.png"
    } else if (input$scene == "sr_br_sb") {
      filename <- "www/sr_br_sb.png"
    }
    # Return a list containing the filename
    list(src = filename,
         width = "20%")
  }, deleteFile = FALSE)
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)

