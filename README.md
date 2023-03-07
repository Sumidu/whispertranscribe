# whispertranscribe

An R based tool that uses Open-AIs whisper to create transcripts from audio.

## Shiny app and R-file

There are two ways how to use whispertranscribe.

### Shiny Application
There is a shiny application in the `WhisperTranscribe` sub-folder. The app is 
located in the single `app.R` file. By running this file the shiny app should 
load.


### R-File
The file `transcribe.R` converts all 


See here https://github.com/openai/whisper for troubleshooting.

It needs Python + the Open-AI library.
```
pip install -U openai-whisper
```



It needs ffmpeg to understand different audio formats.
```
# on Ubuntu or Debian
sudo apt update && sudo apt install ffmpeg

# on Arch Linux
sudo pacman -S ffmpeg

# on MacOS using Homebrew (https://brew.sh/)
brew install ffmpeg

# on Windows using Chocolatey (https://chocolatey.org/)
choco install ffmpeg

# on Windows using Scoop (https://scoop.sh/)
scoop install ffmpeg
```