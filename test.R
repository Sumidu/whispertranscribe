# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Test File ----
#
# Run this file to test if the installation was successful.


# This will setup the python environment and install the required libraries
library(reticulate)

env_name <- "r-whispertranscribe"

# this activates the library, if not possible, restart R.
use_virtualenv(env_name)


py_config()
py_version()

# did it work?
py_list_packages(envname = env_name)


# import libraries
whisper <- reticulate::import("whisper")
certifi <- reticulate::import("certifi")


# actual-test
model <- whisper$load_model("tiny")
out <- whisper$transcribe(model, "input/test.mp3")

if(out[["text"]]=="That is the test for the shiny app."){
  message("Success")
}




# did it work?
# if not and in RStudio, check under Global options whether the correct virtual env 
# is activated


# Common errors ----
## Here are some common errors that can happen 

## SSL Error on a mac?
# https://stackoverflow.com/questions/52805115/certificate-verify-failed-unable-to-get-local-issuer-certificate
## find `install certificates` in the python folder on your system
