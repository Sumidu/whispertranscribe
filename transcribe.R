library(tidyverse)
library(reticulate)
library(lubridate)
# load whisper
whisper <- import("whisper")


filein <- "input/230221_1049.mp3"
fileout <- "output/transcription"

model_list <- whisper$available_models()
message(paste("The following models are available:", paste(model_list, collapse = ", ")))

selected_models <- c("small")

for (model_name in selected_models){
  start_time <- Sys.time()
  model <- whisper$load_model(model_name)
  out = model$transcribe(filein)
  output <- out["text"]$text
  
  results <- c("test")
  for(i in 1:length(out$segments)){
    start <- out$segments[[i]]$start %>% as.period()
    end <- out$segments[[i]]$end %>% as.period()
    seg <- out$segments[[i]]$text
    results <- c(results, paste0(start, "-", end, ":", seg))
  }
  
  write_lines(results, paste0(fileout, "_", model_name, "_bysegments.txt"))
  write_file(out$text, paste0(fileout, "_", model_name, "_full.txt"))
  end_time <- Sys.time()
  message(paste("Timing was", as.period(end_time-start_time)))
}


