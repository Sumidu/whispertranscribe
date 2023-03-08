# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Test File ----
#
# Run this file to test if the installation was successful.

message("Testing configuration...")
# calls config from yaml
config <- config::get()
config$package_manager
# python environment
env_name <- config$env_name

message(paste("Env-name:", env_name))

# This will setup the python environment and install the required libraries
library(reticulate)
library(tidyverse)

# flexible package manager
if(config$package_manager=="conda"){
  message("Using conda...")
  if(conda_list() %>% filter(name==env_name) %>% nrow() < 0){
    stop("Please setup the python virtual environment first. See setup.r.")
  }
  use_condaenv(env_name)  
} else {
  message("Using virtualenv...")
  reticulate::use_python_version("3.8.16")
  # cancel startup if virtual environment does not exist.
  if(!reticulate::virtualenv_exists(env_name)){
    stop("Please setup the python virtual environment first. See setup.r.")
  }
  reticulate::use_virtualenv(env_name)
}



py_config()
py_version()

# did it work?
py_list_packages(envname = env_name)


# import libraries
whisper <- reticulate::import("whisper")

# actual-test
model <- whisper$load_model("tiny")
out <- whisper$transcribe(model, "input/test.mp3")


if(out[["text"]]==" That's the test for the shiny app."){
  message("--- Success ---- ")
  message("--- Success ---- ")
  message("--- Success ---- ")
  message("--- Success ---- ")
}




# did it work?
# if not and in RStudio, check under Global options whether the correct virtual env 
# is activated


# Common errors ----
## Here are some common errors that can happen 

## SSL Error on a mac?
# https://stackoverflow.com/questions/52805115/certificate-verify-failed-unable-to-get-local-issuer-certificate
## find `install certificates` in the python folder on your system
