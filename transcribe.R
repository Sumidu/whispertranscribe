# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Default settings ----
#
# Change these to your individual requirement.
#
# which file-types to convert
file_types <- ".mp3"

# file prefix for output files
output_prefix <- "tr_"
# file extension for output files (raw text)
output_extension <- ".txt"

# default models to use (can be a vector)
selected_models <- c("medium")








# Start of program ----

# load libraries
library(tidyverse)
library(reticulate)
library(lubridate)

# cancel startup if virtual environment does not exist.
if(!reticulate::virtualenv_exists("r-reticulate")){
  stop("Please setup the python virtual environment first. See setup.r.")
}
use_virtualenv("r-reticulate")


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
  fileout <- paste0("output/", output_prefix, str_sub(filein, 1, -4), output_extension)
  message(paste("Now transcribing file:", filein, "Output file:", fileout))
  
  # run all individual models
  for (model_name in selected_models){
    start_time <- Sys.time()
    
    # load the model
    model <- whisper$load_model(model_name)
    # __transcribe the current item ----
    out = model$transcribe(paste0("input/",filein))
    output <- out["text"]$text
    
    # convert individual segments with time codes
    results <- c("")
    for(i in 1:length(out$segments)){
      start <- out$segments[[i]]$start %>% as.period()
      end <- out$segments[[i]]$end %>% as.period()
      seg <- out$segments[[i]]$text
      results <- c(results, paste0(start, "-", end, ":", seg))
    }
    
    write_lines(results, paste0(fileout, "_", model_name, "_bysegments.txt"))
    write_file(out$text, paste0(fileout, "_", model_name, "_full.txt"))
    
    # write time to stdout
    end_time <- Sys.time()
    message(paste("Transcription took", as.period(end_time-start_time)))
  }
}


