# remotes::install_github("bnosac/audio.whisper")

library(audio.whisper)
library(av)
model <- whisper("medium")


audio <- system.file(package = "audio.whisper", "samples", "jfk.wav")
trans <- predict(model, newdata = audio, language = "en", n_threads = 8)

audio_file <- "input/test.wav"


av_audio_convert("input/test.mp3", output = audio_file, format = "wav", sample_rate = 16000)
trans <- predict(model, newdata = audio_file, language = "de", 
                 duration = 30 * 1000, offset = 7 * 1000, 
                 token_timestamps = TRUE, n_threads = 12)
