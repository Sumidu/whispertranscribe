# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup File ----
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

# This will setup the python environment and install the required libraries
library(reticulate)

message("ffmpeg must be installed!")

# install python 3.8.16
install_python(version = "3.8")


# if python install fails on M1 Mac, install open ssl using brew can help

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
#virtualenv_install(env_name, "ffmpeg-python", pip_options = "-U")
#virtualenv_install(env_name, "ffmpeg", pip_options = "-U")


# Check if on MacOS (if so installing tensworflow for mac could unlock GPU)
# Also python 3.8 required
macos <- Sys.info()["sysname"] == "Darwin"
if(macos & py_version()=="3.8"){
  virtualenv_install(env_name, "tensorflow-macos", pip_options = "-U")
  virtualenv_install(env_name, "tensorflow-metal", pip_options = "-U")
}



