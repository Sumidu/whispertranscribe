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
# create a new environment 
virtualenv_create("r-reticulate")

# install whisper and certifi
virtualenv_install("r-reticulate", "openai-whisper", pip_options = "-U")
virtualenv_install("r-reticulate", "certifi", pip_options = "-U")

# this activates the library
use_virtualenv("r-reticulate")

# did it work?
py_list_packages(envname = "r-reticulate")

# import libraries
whisper <- reticulate::import("whisper")
certifi <- reticulate::import("certifi")
# did it work?



# Common errors ----
## Here are some common errors that can happen 

## SSL Error on a mac?
# https://stackoverflow.com/questions/52805115/certificate-verify-failed-unable-to-get-local-issuer-certificate
## find `install certificates` in the python folder on your system
