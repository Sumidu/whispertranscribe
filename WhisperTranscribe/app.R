#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


library(tidyverse)
library(shiny)
library(shinydashboard)
library(shinyjs)
library(gdata)
library(reticulate)
library(howler)
source("../R/timecodes.R")

# calls config from yaml
config <- config::get()
use_python("/opt/homebrew/bin/python3.8")

# configuring maximung size of audio-file
maxsize <- config$shiny_file_size_limit * 1024^2 # 50 MB
options(shiny.maxRequestSize = maxsize)

# python environment
env_name <- config$env_name

# flexible package manager
if(FALSE){
  
  if(config$package_manager=="conda"){
    message("Using conda...")
    if(conda_list() %>% filter(name==env_name) %>% nrow() < 0){
      stop("Please setup the python virtual environment first. See setup.r.")
    }
    use_condaenv(env_name)  
  } else {
    message("Using virtualenv...")
    # cancel startup if virtual environment does not exist.
    if(!reticulate::virtualenv_exists(env_name)){
      stop("Please setup the python virtual environment first. See setup.r.")
    }
    use_virtualenv(env_name)
  }
}

# load whisper and get list of models
whisper <- import("whisper")
modellist <- whisper$available_models()

audio_files_dir <- here::here("WhisperTranscribe","audio")
addResourcePath("sample_audio", audio_files_dir)
audio_files <- file.path("sample_audio", list.files(audio_files_dir, ".mp3$"))
message(audio_files)


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
ui <- dashboardPage(
  dashboardHeader(title = "WhisperTranscribe"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    shinyjs::useShinyjs(),

    # Sidebar with a slider input for number of bins 
    fluidRow(
        # settings box ----
        box(width = 4,
            h2("Instructions"),
            p(strong("Step 1:"), paste("Load a model. Models are cached locally after the first download.",
                    "Larger models take longer to download (e.g., base = 150 MB, small = 500 MB, medium = 1.5 GB, large = 2.8 GB)")),
            p(a(href="https://github.com/openai/whisper", "Click here for more details.", target="_blank")),
            p(strong("Step 2:"), paste("Then select an audio-file to upload (.mp3). File size limit:", gdata::humanReadable(maxsize))),
            p(strong("Step 3:"), paste("Last click on transcribe. Larger models take longer for transcription.")),
            p("You can change the model without changing the audio, to try different results. The small model is a usable version."),
            br(),
            #pre(id = "console"),
            br(),
            selectInput("selected_model", "Select a model", choices = modellist,selected = "tiny"),
            actionButton("loadmodel", "Load model", icon = icon("download")),br(),br(),
            fileInput("audiofile", "Choose an audio file",
                      multiple = FALSE,
                      accept = c(".mp3", "audio/mpeg", "audio/mp4", "audio/vnd.wav", "audio/*")),
            checkboxInput("timecodes", "Use timecodes"),
            actionButton("transcribe", "Transcribe Audio", icon = icon("ear-listen")),
            br()
        ),
        
        # output box ----
        box(width = 8,
          # ACV: TODO put back in
          h2("Audio"),
          div(
            class = "howler-module",
            style = paste0("width:", "400px", ";"),
            howler(
              elementId = "sound", 
              tracks = audio_files,
              auto_continue = TRUE,
              auto_loop = TRUE,
              seek_ping_rate = 1000
            ),
            div(
              class = "howler-module-container",
              howlerPlayPauseButton("sound"),
              tags$span(howlerSeekSlider("sound")),
              span(
                class = "howler-module-duration",
                "Duration:",
                textOutput("sound_seek", container = tags$strong, inline = TRUE),
                "/",
                textOutput("sound_duration", container = tags$strong, inline = TRUE)
              ),
              div(
                class = "howler-module-volume",howlerVolumeSlider("sound"))
            ),
          ),
          h2("Transcription output"),
          textOutput("language"),
          verbatimTextOutput("result", placeholder = TRUE)
      ),
      # debug box ----
      box(width=8, collapsible = TRUE, title = "Debug information", collapsed = TRUE,
          verbatimTextOutput("debug")
          )
    )
  )
)

# Server ----
server <- function(input, output, session) {
  
  observe({
    #req(FALSE)
    req(input$audiofile)
    
      #message(paste("Workingfile:", input$audiofile$datapath))
      addResourcePath("upload_audio", dirname(input$audiofile$datapath))
      
      # ACV TODO: fix uploaded audio
      outfile <- paste0("upload_audio/", basename(input$audiofile$datapath))
      #message(outfile)
                        
      howler::addTrack("sound", outfile)
      howler::changeTrack("sound", outfile)
      howler::pauseHowl("sound")
    })
  
  output$sound_duration <- renderText({
    sprintf(
      "%02d:%02.0f",
      input$sound_duration %/% 60,
      input$sound_duration %% 60
    )
  })
  
  output$sound_seek <- renderText({
    sprintf(
      "%02d:%02.0f",
      input$sound_seek %/% 60,
      input$sound_seek %% 60
    )
  })

  # prepare the UI ----
  shinyjs::disable("transcribe")
  model <- reactiveVal(NULL)
  text_output <- reactiveVal(NULL)
  
  # actionbutton load ----
  observeEvent(input$loadmodel, {
    withProgress(message = paste('Loading Model:',input$selected_model), value = 0, {
      incProgress(0.25, detail = paste("Loading bar will not move. This may take a while."))
      
      # load the model into the reactive val
      start_time <- Sys.time()
      model(whisper$load_model(input$selected_model))
      end_time <- Sys.time()
      showModal(modalDialog(
        title = "Load complete",
        paste("Model loaded in", lubridate::as.duration(end_time-start_time)),
        easyClose = TRUE,
        footer = NULL
      ))
      incProgress(1, detail = paste("Model loaded."))
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
        withProgress(message = paste('Transcribing using model:',input$selected_model), value = 0, {
          
          incProgress(0.25, detail = paste("Loading bar will not move. This may take a while"))
          
          # transcribe the audio ----
          start_time <- Sys.time()
          out <- model()$transcribe(input$audiofile$datapath)
          end_time <- Sys.time()
          message(paste("Transcription took", lubridate::as.duration(end_time-start_time)))
          incProgress(1, detail = paste("Transcription finished in", lubridate::as.duration(end_time-start_time)))
          showModal(modalDialog(
            title = "Transcription complete",
            paste("Transcription finished in", lubridate::as.duration(end_time-start_time)),
            easyClose = TRUE,
            footer = NULL
          ))
        })
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
    
    #write the reactive value
    text_output(out)
  })
  

  output$language <- renderText({
    req(input$audiofile)
    req(model())
    
    source_python("../python/detectlang.py")
    withProgress(message = 'Detecting Language', value = 0, {
      incProgress(0.25, detail = paste0("Using model: ", input$selected_model, ". This should not take too long."))
      probs <- detectlang(input$audiofile$datapath, model())
      incProgress(1, detail = paste("Done."))
    })
    lang <- names(probs[which.max(probs)])
    
    paste("Detected language:", lang)
  })
  
  # rendering our transcription result ----
  output$result <- renderText({
    res <- ""
    if(!is.null(text_output())){
      if(input$timecodes) {
        out <- text_output()$segments
        
        results <- c(" ")
        
        for(i in 1:length(out)){
          
          start <- seconds_to_timecode( out[[i]]$start )
          end <- seconds_to_timecode( out[[i]]$end )
          segment_text <- out[[i]]$text
          results <- c(results, paste0(start, "-", end, ": ", stringr::str_wrap(segment_text), "\n"))
        }
        res <- results
      } else {
        res <- stringr::str_wrap(text_output()["text"]$text)
      }
    }
    res
  })
  
  
  
  output$debug <- renderText({
    conf <- py_config()
    packs <- py_list_packages()
    
    print_conf <- capture.output(print(conf))
    print_packs <- capture.output(print(packs))
    paste(
      paste(print_conf, collapse = "\n"), "\n\nPackage info:\n\n",
      paste(print_packs, collapse = "\n")
    )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
