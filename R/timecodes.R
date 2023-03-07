
#' Function to convert seconds to a timecode
#'
#' @param s time in seconds
#'
#' @return a string that uses hh:mm:ss formatting
#' @export
seconds_to_timecode <- function(s){
  if(s < 0) {
    warning("Negative seconds cannot be converted to a timecode.")
  }
  seconds <- s %% 60
  s <- (s - seconds) / 60
  minutes <- s %% 60
  s <- (s - minutes) / 60
  hours <- s
  paste0(
    str_pad(hours, 2, pad = "0"), ":",
    str_pad(minutes, 2, pad = "0"), ":",
    str_pad(seconds, 2, pad = "0"))
  
}