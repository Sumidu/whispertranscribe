# whispertranscribe

An R based tool that uses Open-AIs whisper to create transcripts from audio.

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