# Packages
# ========================================================================================================
library("rjson")
library("XML")
library("gsubfn")

# Functions
# ========================================================================================================

# from http://stackoverflow.com/questions/5060076/convert-html-character-entity-encoding-in-r
html2txt <- function(str) {
  xpathApply(htmlParse(str, asText=TRUE),
             "//body//text()", 
             xmlValue)[[1]] 
}


getUrlsFromTopWeek <- function(urlTop){
  topWeekHtml <- htmlParse(urlTop)
  urls <- xpathSApply(topWeekHtml, "//*[@id='conteudo-principal']/section[*]/article[*]/p/a", xmlGetAttr, "href")  
}


unlistNoEmpty <- function(someList){
  selectEmpty <- sapply(someList, length) == 0
  someList[selectEmpty] <- NA
  unlist(someList)
}


tryReadJson <- function(jsonUrl, ntry =3){
  readPageTryCount <- 0
  while(readPageTryCount != 3){
    jsonLines <- readLines(jsonUrl, warn = FALSE)
    jsonString <- paste(jsonLines, collapse = "")
    
    options("warn" = -1)     # To avoid last line warning from fromJSON
    jsonData <- try(fromJSON(jsonString), silent = TRUE)
    options("warn" = 0) # return to the norml warning behavior
    
    if(class(jsonData) == "try-error"){
      readPageTryCount <- readPageTryCount + 1
      print(paste(readPageTryCount, "failed attempt to read X", jsonUrl))
    } else {
      readPageTryCount <- 3
    }
  }
  return(jsonData)
}


getUolComment <- function(pagePatch){
  pageHtlm <- readLines(pagePatch, warn = FALSE)
  
  commentId <- strapplyc(pageHtlm, "Comentario=\\{\"id\":(\\d+)")[[1]]
  
  # If is from Folha instead of UOL or is from a section that is not article
  if(length(commentId) == 0){
    return(NULL)
  }
    
  # we are not interest in the replies for now
  commentPath <- paste("http://view.comentarios.uol.com.br/subject/", commentId, "?size=10000&load_replies=false", sep = "")
  commentInfo <- tryReadJson(jsonUrl = commentPath)
  
  # if there is no comments
  if(length(commentInfo$docs) == 0){
    return(NULL)
  }
  
  commentHeaders <- names(commentInfo$docs[[1]])
  commentTable <- t(sapply(commentInfo$docs, unlistNoEmpty))
  colnames(commentTable) <- commentHeaders
  # The comments (they are in the 'content' field) need to be parse to text
  commentTable[,"content"] <- sapply(commentTable[,"content"], html2txt)
  
  return(commentTable)
}


# Get comments from the top articles of the last 30 weeks from UOL
# ========================================================================================================

url.indexTopWeekArticle <- "http://noticias.uol.com.br/top-da-semana/ultimas/"
html.indexTopWeekArticle <- htmlParse(url.indexTopWeekArticle)

url.topWeekArticles<- xpathSApply(html.indexTopWeekArticle, "//*[@id='conteudo-principal']/div[*]/section/section[*]/article/h1/a", xmlGetAttr, "href")

url.articles <- lapply(url.topWeekArticles, getUrlsFromTopWeek)


allTopList <- list()
countWeek <- 1
for(week in url.articles){
  print(paste("WEEK:", countWeek))  
  listWeekComments <- list()
  countArticles <- 1
  for(article in week){
    print(paste("ARTICLE:", countArticles))
    listWeekComments[[countArticles]] <- getUolComment(article)
    countArticles <- countArticles + 1
  }
  # remove the ones that no comment was retrieve
  selectFolha <- sapply(listWeekComments, is.null)
  listWeekComments[selectFolha] <- NULL
  
  weekTable <- do.call(rbind, listWeekComments)
  allTopList[[countWeek]] <- weekTable
  countWeek <- countWeek + 1
}


# Format and export the tables
# ========================================================================================================

weekName <- gsub("^.*/|\\.htm", "", url.topWeekArticles)
weekNameFilesPath <- paste("../commentTables/", weekName, ".csv", sep = "")
names(allTopList) <- weekNameFilesPath
for(csv in names(allTopList)) write.csv(allTopList[[csv]], csv, row.names = FALSE)
