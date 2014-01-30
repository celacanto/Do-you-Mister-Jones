source("makeMarkovInputs.R")
source("createCommentUol.R")

# Get the tables files with the comments informations of eche week
tablesFiles <- list.files("../commentTables/", pattern = "\\.csv", full.names = TRUE)
# read it
allWeeksTables <- lapply(tablesFiles, read.csv, stringsAsFactors = FALSE)
# merge it
allcomments <- do.call(rbind, allWeeksTables) 

# This will take some time...
# Is getting the transitions and start probability of the markov chain
## the nWordsByState set the randoness of the output
#   with high number the text will be less random, but it will increase the change
#   of the text be just the copy of a comment made on the site.
# This parameter have to be balanced with the sizeParameter
markovsProp <- markovCommentInput(allcomments, nWordsByState = 2, 
                                  removeNewLine = FALSE, 
                                  lowerCases = TRUE, 
                                  removeParentheses = TRUE)

generateComment(markovsProp, sizeParameter = 5)