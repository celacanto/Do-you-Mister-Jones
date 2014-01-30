generateComment <- function(markovsProp, sizeParameter  = 50){
  
  statePresent <- sample(x = markovsProp$startVector, size = 1)
  
  text <- statePresent
  wordsOnText <- unlist(strsplit(text, " +"))
  nWordsByState <- length(wordsOnText)
  nWords <- nWordsByState

  repeat{
    
    # If there is nowhere to go...
    if(is.null(markovsProp$transitionList[[statePresent]])){
      break
    }
    
    nextWord <- sample(x = markovsProp$transitionList[[statePresent]], size = 1)
    text <- paste(text, nextWord)
    
    # if the text is upper the sizeParameter...
    if(nWords >= sizeParameter){
      # ..it will end when the last word have a dot in it
      endDot <- grepl("\\.$", nextWord)
      if(endDot){
        break
      }
    }
    
    wordsOnText <- c(wordsOnText, nextWord)
    lastWords <- tail(wordsOnText, nWordsByState)
    statePresent <- paste(lastWords, collapse = " ")
    nWords <- nWords + 1
  }
  
  return(text)
  
}

