# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup File 
#
# Run this file line by line before using any of the other files.
# Running this line by line helps with identifying problems.
#
# It will restore the R-Environment (libraries, etc.) and create a 
# python environment with the required libraries.
# You will need to manually install ffmpeg (e.g. using brew).
# Conda will update the environment, while virtualenv will rebuild the 
# environment, if it already exists.
# See the end of this file for a list of common problems.


# renv restore ----
message("Setting up renv")
if(is.null(installed.packages("renv"))){
  install.packages("renv")
}
# This will restore the r_environment from the lockfile
renv::restore()


# This will setup the python environment and install the required libraries
library(reticulate)
library(tidyverse)

# config load ----
message("Loading configuration from config.yaml.")
# calls config from yaml
config <- config::get()
# python environment
env_name <- config$env_name

message(paste("Setting up env-name:", env_name))

# flexible package manager
if(config$package_manager=="conda"){
  # Conda setup ----
  message("Using conda...")
  if(dir.exists(miniconda_path())){
    message("Updating Miniconda")
    miniconda_update()
  } else {
    reticulate::install_miniconda()  
  }
  message(paste("Using",conda_version()))
  
  
  if(conda_list() %>% filter(name==config$env_name) %>% nrow() > 0){
    message("Matching environment found.")
    #conda_remove(config$env_name)
  } else {
    message("Creating conda environment...")
    conda_create(config$env_name, python_version = config$python_version)
    message("Installing whisper using pip...")
    conda_install(config$env_name, c("openai-whisper"), pip = TRUE, pip_options = "-U")
  }
  use_condaenv(env_name)
  } else 
  {
  
    
  # virtualenv setup ----
  message("Using virtualenv...")
  # cancel startup if virtual environment does not exist.
  envs <- virtualenv_list()
  if(env_name %in% envs){
    #remove existing environment for clean start
    reticulate::virtualenv_remove(env_name)
  }
  # create a new environment 
  py_path <- reticulate::install_python(config$python_version)  
  reticulate::virtualenv_create(env_name, python = py_path)
  

  # install whisper and certifi
  virtualenv_install(env_name, "openai-whisper", pip_options = "-U")
  use_virtualenv(env_name)
}

message("FFmpeg must be installed!")



# NOTES: Common problems ----
#
# On M1 Macs even the the virtual/conda environment is set up. Running whisper
# may fail, due to ffmpeg being not available.
# I don't know where this problem comes from. Maybe because it uses 
# the native python install from macos.
#