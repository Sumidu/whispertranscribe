library(reticulate)


# create a new environment 
virtualenv_create("r-reticulate")

# install SciPy
virtualenv_install("r-reticulate", "openai-whisper", pip_options = "-U")
virtualenv_install("r-reticulate", "certifi", pip_options = "-U")


use_virtualenv("r-reticulate")

py_list_packages(envname = "r-reticulate")

# import SciPy (it will be automatically discovered in "r-reticulate")
whisper <- reticulate::import("whisper")
certifi <- reticulate::import("certifi")


## SSL Error?
# https://stackoverflow.com/questions/52805115/certificate-verify-failed-unable-to-get-local-issuer-certificate
## find install certificates in the python folder.
