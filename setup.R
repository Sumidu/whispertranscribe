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


## Here are some common errors that can happen

## SSL Error on a mac?
# https://stackoverflow.com/questions/52805115/certificate-verify-failed-unable-to-get-local-issuer-certificate
## find install certificates in the python folder.
