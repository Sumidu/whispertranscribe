# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Default settings ----
#
# Change these to your individual requirement.
#
# which file-types to convert
file_types <- ".mp3"

# file prefix for output files
output_prefix <- "tr_"
# file suffix after initial_file for output files (raw text)
output_suffix <- ""

# default models to use (can be a vector)
# medium is a good model for transcribing non-english audio
selected_models <- c("tiny")  



# calls config from yaml
config <- config::get()
config$package_manager
# python environment
env_name <- config$env_name



# Start of program ----

# load libraries
library(tidyverse)
library(reticulate)
library(lubridate)
library(av)

# flexible package manager
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


source("R/timecodes.R")

# load whisper
whisper <- import("whisper")
model_list <- whisper$available_models()
message(paste("The following models are available:", paste(model_list, collapse = ", ")))

# load file list
file_in_list <- dir("input", pattern = file_types)
message(paste("Converting", length(file_in_list), "files..."))

# _iterate over all files ----
for(filein in file_in_list){
  #generate output name
  # find the . in the filename 
  dot_positions <- str_locate_all(filein, "\\.")[[1]]
  dot_pos <- dot_positions[nrow(dot_positions),1]
  fileout <- paste0("output/", output_prefix, str_sub(filein, 1, dot_pos - 1), output_suffix)
  info <- av::av_media_info(paste0("input/",filein))
  message(paste0("Now transcribing file: ", filein, " - Output file: ", fileout, " - File length:", info$duration %>% as.duration()))
  
  # run all individual models
  for (model_name in selected_models){
    start_time <- Sys.time()
    
    # load the model
    model <- whisper$load_model(model_name)
    
    # __transcribe the current item ----
    out = model$transcribe(paste0("input/",filein))
    
    output <- out["text"]$text
    
    # convert individual segments with time codes
    results <- c()
    for(i in 1:length(out$segments)){
      start <- out$segments[[i]]$start %>% seconds_to_timecode()
      end <- out$segments[[i]]$end %>% seconds_to_timecode()
      segment_text <- out$segments[[i]]$text
      results <- c(results, paste0(start, "-", end, ":", segment_text))
    }
    
    write_lines(results, paste0(fileout, "_", model_name, "_bysegments.txt"))
    write_file(out$text, paste0(fileout, "_", model_name, "_full.txt"))
    
    # write time to stdout
    end_time <- Sys.time()
    message(paste("Transcription took", as.duration(end_time-start_time)))
  }
}

message("Done.")

