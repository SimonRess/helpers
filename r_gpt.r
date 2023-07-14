# Requirements:
# 1. Create an OpenAI API account at https://auth0.openai.com/u/signup
# 2. Create here (https://platform.openai.com/account/api-keys) an API key and copy it
# 3. Insert the API key into the Sys.setenv() function below and run it

Sys.setenv(openai_secret_key = "***")

if(!require("dplyr")) install.packages("dplyr")
library(dplyr)
if(!require("httr")) install.packages("httr")
library(httr)
if(!require("jsonlite")) install.packages("jsonlite")
library(jsonlite)

g = function(prompt = NULL, apiKey= Sys.getenv("openai_secret_key"), reset = FALSE) { #, log.file=FALSE
  
#Logging console output
  #if(log.file){
    #log = file("logfile.txt") 
    #sink(log, append = TRUE, type = "output")
    #sink(log, append = TRUE, type = "message")
  #}
  
  
#Prompt Engineering: Specify output format/content-type
prompt.embedded = paste(
"You are an R coding assistant. For the rest of this conversation, return R code only.
Do not include anything else such as extra characters or comments.
DO NOT install any packages but assume I already have them installed.
Prompt: ",  substr(prompt,2, nchar(prompt)))

#Create initial context
  if(!exists("openai_completions") | reset){
    openai_completions<<-
    list(
      list(
        role = 'user',
        content = prompt.embedded
        )
      )
  }

#add prompt to context
  openai_completions <<-
        append(
          openai_completions,
          list(
            list(
              role = 'user',
              content = substr(prompt,2, nchar(prompt))
            )
          )
        )

#Post request
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", apiKey)),
    content_type_json(),
    encode = "json",
    body = list(
      model = "gpt-3.5-turbo",
      temperature = 0.5,
      #messages = list(list(
      #  role = "user",
      #  content = as.character(openai_completions)
      #))
      messages = openai_completions
    )
  )

#Save Response
  print = content(response)$choices[[1]]$message$content
  #rough check if response is R Code, contains functions, flag as a comment
  if(!grepl("[a-z]\\(", print)) print = paste0("#", print)


#Send prompt to console
  rstudioapi::sendToConsole(paste0("#",prompt), execute = TRUE)
  
#Send the R comments to the console
  rstudioapi::sendToConsole(code = print %>%
                              stringr::str_remove('^\n') %>%
                              stringr::str_remove('^R') %>%
                              stringr::str_remove_all('\\`\\`\\`\\{r\\}') %>%
                              stringr::str_remove_all('\\`\\`\\`') %>%
                              stringr::str_trim(side = 'left'),
                              execute = TRUE, echo = TRUE)



#add response to context
  openai_completions <<-
        append(
          openai_completions,
          list(
            content(response)$choices[[1]]$message
          )
        )

  
#Close connection to log file
  #if(log.file){
    #closeAllConnections()
  #}
  
    
}


# Examplary Usage

g("#What is the iris dataset about?", reset = TRUE)

g("Return an overview of the iris dataset")

#r_gpt("#Write some R code that makes a boxplot of Petal.Length from the iris data set using the ggplot2 package", reset = TRUE)
g("#Create a boxplot of Petal.Length using the ggplot2 package")

g("#Now group and adjust the color by the variable Species")

g("#Use a more minimal theme")

g("#Make the plot prettier")

g("#Add an appropriate title")

#####################
auto = mtcars

g("#Check the columns in the 'auto' dataframe", reset = TRUE)

g("#Create a boxplot this data using ggplot2")

g("#Group it by 'cyl")

#############################

g("Download the https://vincentarelbundock.github.io/Rdatasets/csv/AER/CPS1985.csv data into R", reset = TRUE)

g("What this dataframes structure?")

g("Create a Correlation matrix using model.matrix and ggcorrplot")

g("Decrease the text size")
g("Decrease the text size some more")

g("Visualise the connection between 'wage', 'experience' and 'sector' in a scatterplot using ggplot2")

g("Add in this plot regression lines for the effect of 'sector' on 'wage'")

#############################

g("Save https://vincentarelbundock.github.io/Rdatasets/datasets.html last table as R dataframe, using rvest", reset=T)

g("Whats the str of this data?")

g("What are to top 5 'Package'?")

g("For this top 5 visualize the number of 'Item' using ggplot2")

g("Adjust the color by 'Package'")

g("Visualize the 'Rows' by 'Cols' in a scatterplot using ggplot2")

g("Drop extreme values")

g("Run a cluster analysis on 'Rows' and 'Cols' and visualize the result")

g("Use Fuzzy Clustering and visualize by clustering and membership")

g("Differentiate the Cluster by color and the Membership by color intensity")
