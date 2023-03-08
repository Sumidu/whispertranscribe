#
#
#
#
#
#
#
#       THIS FILE CONTAINS SOME CODE JUNK USED FOR TESTING


# install python 3.8.16
#install_python(version = "3.8")
# if python install fails on M1 Mac, install open ssl using brew can help

#py_config()
#py_version()


#envs <- virtualenv_list()
#if(env_name %in% envs){
#remove existing environment for clean start
#  virtualenv_remove(env_name)
#}
# create a new environment 
#virtualenv_create(env_name)

# install whisper and certifi
#virtualenv_install(env_name, "openai-whisper", pip_options = "-U")
#virtualenv_install(env_name, "certifi", pip_options = "-U")
#virtualenv_install(env_name, "ffmpeg-python", pip_options = "-U")
#virtualenv_install(env_name, "ffmpeg", pip_options = "-U")


# Check if on MacOS (if so installing tensworflow for mac could unlock GPU)
# Also python 3.8 required


#macos <- Sys.info()["sysname"] == "Darwin"
#if(macos & py_version()=="3.8"){
#  virtualenv_install(env_name, "tensorflow-macos", pip_options = "-U")
#  virtualenv_install(env_name, "tensorflow-metal", pip_options = "-U")
#}
