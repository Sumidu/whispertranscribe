#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



library(shiny)
library(shinyjs)
library(gdata)
library(reticulate)

# configuring maximung size of audio-file
maxsize <- 50 * 1024^2 # 50 MB
options(shiny.maxRequestSize = maxsize)

# cancel startup if virtual environment does not exist.
if(!reticulate::virtualenv_exists("r-reticulate")){
  stop("Please setup the python virtual environment first. See setup.r.")
}

use_virtualenv("r-reticulate")

# load whisper and get list of models
whisper <- import("whisper")
modellist <- whisper$available_models()


# utility function for debugging python output 
# currently not used, as no live output possible :-/
withConsoleRedirect <- function(containerId, expr) {
  # Change type="output" to type="message" to catch stderr
  # (messages, warnings, and errors) instead of stdout.
  txt <- py_capture_output(results <- expr, type = c("stdout", "stderr"))
  if (length(txt) > 0) {
    insertUI(paste0("#", containerId), where = "beforeEnd",
             ui = paste0(txt, "\n", collapse = "")
    )
  }
  results
}

# Define UI for application that draws a histogram
ui <- fluidPage(
    shinyjs::useShinyjs(),
    # Application title
    titlePanel("OpenAI - Whisper - Shiny app"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
       
          h2("Instructions"),
          p(strong("Step 1:"), paste("Load a model. Models are cached locally after the first download.",
                  "Larger models take longer to download (e.g., small = 250 MB, medium = 750 MB, large = 1.5 GB)")),
          p(a(href="https://github.com/openai/whisper", "Click here for more details.", target="_blank")),
          p(strong("Step 2:"), paste("Then select an audio-file to upload (.mp3). File size limit:", gdata::humanReadable(maxsize))),
          p(strong("Step 3:"), paste("Last click on transcribe. Larger models take longer for transcription.")),
          p("You can change the model without changing the audio, to try different results."),
          br(),
          #pre(id = "console"),
          br(),
          selectInput("selected_model", "Select a model", choices = modellist,selected = "tiny"),
          actionButton("loadmodel", "Load model", icon = icon("download")),br(),br(),
          fileInput("audiofile", "Choose an audio file",
                    multiple = FALSE,
                    accept = c(".mp3")),
          actionButton("transcribe", "Transcribe Audio", icon = icon("ear-listen")),
          br()
        ),

        # Show a plot of the generated distribution
        mainPanel(
          h2("Transcription output"),
          textOutput("language"),
          verbatimTextOutput("result")
          
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  # prepare the UI
  shinyjs::disable("transcribe")
  model <- reactiveVal(NULL)
  text_output <- reactiveVal("")
  
  # actionbutton load ----
  observeEvent(input$loadmodel, {
    withProgress(message = 'Loading Model', value = 0, {
      incProgress(0.25, detail = paste("Loading model", input$selected_model, "This may take a while"))
      
      # load the model into the reactive val
      model(whisper$load_model(input$selected_model))
      
      incProgress(1, detail = paste("Model loaded"))
    })
    shinyjs::enable("transcribe")
  })
  
  # actionbutton transcribe ----
  observeEvent(input$transcribe, {
    req(input$audiofile)
    req(model)
    tryCatch(
      {
        #model <- whisper$load_model("small")
        withProgress(message = 'Loading Model', value = 0, {
          
          incProgress(0.25, detail = paste("Transcribing Audio", input$selected_model, "This may take a while"))
          
          # transcribe the audio
          out <- model()$transcribe(input$audiofile$datapath)
          
          incProgress(1, detail = paste("Transcription finished..."))
        })
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
    
    #write the reactive value
    text_output(out["text"]$text)
  })
  
  
  output$language <- renderText({
    req(input$audiofile)
    req(model())
    
    source_python("../detectlang.py")
    withProgress(message = 'Detecting Language', value = 0, {
      incProgress(0.25, detail = paste("Language detection using", input$selected_model, "\nThis should not take too long."))
      probs <- detectlang(input$audiofile$datapath, model())
      incProgress(1, detail = paste("Done."))
    })
    lang <- names(probs[which.max(probs)])
    
    paste("Detected language:", lang)
  })
  
  output$result <- renderText({
    text_output()    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
