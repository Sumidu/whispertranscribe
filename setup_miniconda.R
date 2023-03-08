# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup File for miniconda----
#
# Run this file before using any of the other files.
#
# It will restore the R-Environment (libraries, etc.) and create a 
# python environment with the required libraries.
# You will need to manually install ffmpeg (e.g. using brew).
# See the end of this file for a list of common problems.


if(is.null(installed.packages("renv"))){
  install.packages("renv")
}
# This will restore the r_environment from the lockfile
renv::restore()

# calls config from yaml
config <- config::get()
config$package_manager

# This will setup the python environment and install the required libraries
library(reticulate)
library(tidyverse)

if(dir.exists(miniconda_path())){
  message("Updating Miniconda")
  miniconda_update()
} else {
  reticulate::install_miniconda()  
}
message(paste("Using",conda_version()))


if(conda_list() %>% filter(name==config$env_name) %>% nrow() > 0){
  message("Matching environment found.")
} else {
  message("Creating conda environment...")
  conda_create(config$env_name)
  message("Installing whisper using pip...")
  conda_install(config$env_name, c("openai-whisper"), pip = TRUE, pip_options = "-U")
}

use_condaenv(config$env_name)

whisper <- import("whisper")
model <- whisper$load_model("tiny")
out <- model$transcribe("input/test.mp3")
