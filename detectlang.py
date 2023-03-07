def detectlang(file, model):
  import whisper
  
  # load audio and pad/trim it to fit 30 seconds
  audio = whisper.load_audio(file)
  audio = whisper.pad_or_trim(audio)
  # make log-Mel spectrogram and move to the same device as the model
  mel = whisper.log_mel_spectrogram(audio).to(model.device)
  _, probs = model.detect_language(mel)
  return probs
