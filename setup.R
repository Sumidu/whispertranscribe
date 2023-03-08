# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup File ----
#
# Run this file before using any of the other files.
#
# It will restore the R-Environment (libraries, etc.) and create a 
# python environment with the required libraries.
# You will need to manually install ffmpeg (e.g. using brew).
# See the end of this file for a list of common problems.



# This will restore the r_environment from the lockfile
renv::restore()

# This will setup the python environment and install the required libraries
library(reticulate)

message("ffmpeg must be installed!")

# install python 3.8.16
install_python(version = "3.8")

py_config()
py_version()

env_name <- "r-whispertranscribe"

envs <- virtualenv_list()
if(env_name %in% envs){
  #remove existing environment for clean start
  virtualenv_remove(env_name)
}
# create a new environment 
virtualenv_create(env_name)

# install whisper and certifi
virtualenv_install(env_name, "openai-whisper", pip_options = "-U")
virtualenv_install(env_name, "certifi", pip_options = "-U")
virtualenv_install(env_name, "ffmpeg-python", pip_options = "-U")
virtualenv_install(env_name, "ffmpeg", pip_options = "-U")


# Check if on MacOS (if so installing tensworflow for mac could unlock GPU)
# Also python 3.8 required
macos <- Sys.info()["sysname"] == "Darwin"
if(macos & py_version()=="3.8"){
  virtualenv_install(env_name, "tensorflow-macos", pip_options = "-U")
  virtualenv_install(env_name, "tensorflow-metal", pip_options = "-U")
}



# this activates the library
use_virtualenv(env_name)



# did it work?
py_list_packages(envname = env_name)


# import libraries
whisper <- reticulate::import("whisper")
certifi <- reticulate::import("certifi")
# did it work?
# if not and in RStudio, check under Global options whether the correct virtual env 
# is activated

# test
model <- whisper$load_model("tiny")
out <- whisper$transcribe(model, "input/test.mp3")
out[["text"]]$text


# Common errors ----
## Here are some common errors that can happen 

## SSL Error on a mac?
# https://stackoverflow.com/questions/52805115/certificate-verify-failed-unable-to-get-local-issuer-certificate
## find `install certificates` in the python folder on your system
