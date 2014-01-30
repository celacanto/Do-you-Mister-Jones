# Functions
# ========================================================================================================

splitInWords <- function(comment){
  unlist(strsplit(comment, " +"))
}

nConsecutiveWords <- function(words, n, indexStart){
  words[indexStart:(indexStart + n)]
}

allNConsecutiveWords <- function(words, n){
  indexes <- head(seq_along(words), -n)
  lapply(indexes, nConsecutiveWords, words = words, n = n)
}

stateAndNextWord <- function(setOfWords, nWordsByState){
  t(sapply(setOfWords, function(x) c("state" = paste(x[1:nWordsByState], collapse = " "),
                                   "nextWord" = x[nWordsByState + 1])))   
}

wordsPairState <- function(words){
  stateFirstWords <- head(words, - 1)
  # When the comment have only one word
  if(is.null(stateFirstWord)){
    return(NULL)
  }
  stateSecondWords <- tail(words, -1)
  states <- mapply(paste, stateFirstWords, stateSecondWords, USE.NAMES = FALSE)   
  # remove the last one (as it will don't have a word to go to)
  states  <- head(states, -1)
  return(states)
}

markovCommentInput <- function(commentTable, nWordsByState = 2, removeNewLine = FALSE, lowerCases = FALSE, 
                               removeParentheses = TRUE # parenthesis and quotes. 
                               ){
  
  comments <- commentTable$content 
  
  if(removeNewLine){
    comments <- gsub(pattern = "\\\\n", "", comments)
  }
  if(lowerCases){
    comments <- tolower(comments)
  }
  # There is a problem in balacing parenthesis, quotes, brackets, etc in the this type of program
  # The solution I have seen is:
  #  * remove the parentheses
  #  * consider everything inside the parenthesis one word (you will probably end with the tree states from the same comment)
  if(removeOpenCloseEstructures){
    comments <- gsub("\\(.*?\\)" , "", comments)
    comments <- gsub("\".*?\"" , "" , comments)
  }
  
  # Correct the comment that don't a space after a punctuation
  regexBadFormat <- "([\\.\\,\\!\\:\\?]+)([^[:blank:][:punct:][:space:]])"
  comments <- gsub(pattern = regexBadFormat, replacement = "\\1 \\2", comments)
    
  words <- lapply(comments, splitInWords)
  nWordsByComments <- sapply(words, length)
  words[nWordsByComments < (nWordsByState + 1)] <- NULL
  
  consecutiveWords <- lapply(words, allNConsecutiveWords, n = nWordsByState)  
  stateNextWordList <- sapply(consecutiveWords, stateAndNextWord, nWordsByState = nWordsByState)
  
  startStates <- sapply(stateNextWordList, function(x) x[1,1])
  
  tableStateNextWordDF <- as.data.frame(do.call(rbind, stateNextWordList))
  transitions <- split(as.character(tableStateNextWordDF$nextWord), tableStateNextWordDF$state)
  
  return(list("startVector" = startStates, "transitionList" = transitions))
}


comments <- comments[grep("próximas eleições", comments)][grep("não tem",  comments[grep("próximas eleições", comments)])][c(1,3,4)]
tabelas <- lapply(consecutiveWords, function(x) matrix(unlist(x), ncol = 3, dimnames = list(c(), c("primeira", "segunda", "terceira"))))
