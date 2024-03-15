
# Find the current version here:
# - llm: 
# - diffusion:


# Requirements:
# 1. Create an OpenAI API account at https://auth0.openai.com/u/signup
# 2. Register your payment method here (https://platform.openai.com/account/billing/payment-methods); Costs <1Cent per message
# 3. Choose a max payment per month (e.g. 2€) here (https://platform.openai.com/account/billing/limits)
# 4. Create here (https://platform.openai.com/account/api-keys) an API key and copy it
# 5. Insert the API key into the Sys.setenv() function below and run it

Sys.setenv(openai_secret_key = "***") # api_key

# Usage
# 1. Install & load packages below
# 2. Define the g() function -> run line 22-115 at once
# 3. Send your question / command by running g("your question or command") 

if(!require("dplyr")) install.packages("dplyr")
library(dplyr)
if(!require("httr")) install.packages("httr")
library(httr)
if(!require("jsonlite")) install.packages("jsonlite")
library(jsonlite)



#----------------------#
## Image Generation ####
#----------------------#

# The Images API provides three methods for interacting with images:
# 
# - Creating images from scratch based on a text prompt (DALL·E 3 and DALL·E 2)
# - Creating edited versions of images by having the model replace some areas of a pre-existing image, based on a new text prompt (DALL·E 2 only)
# - Creating variations of an existing image (DALL·E 2 only)

#library("png")

# if(!require("RCurl")) install.packages("RCurl")
#   library("RCurl")
# 
# if(!require("imager")) install.packages("imager")
#   library("imager")
if(!require("magick")) install.packages("magick")
  library("magick")

 

# Generations

  OPENAI_API_KEY = Sys.getenv("openai_secret_key")
  model = "dall-e-3"
  size = "1024x1024"
  prompt = "A Corgi sleeping on its tummy" # "a white siamese cat with big paws"

  # URL und Payload für die Anfrage
    url <- "https://api.openai.com/v1/images/generations"
    payload <- list(
      model = model,
      prompt = paste0("I NEED to test how the tool works with extremely simple prompts. DO NOT add any detail, just use it AS-IS: ", prompt),
      n = 1,
      size = size
    )
  
  # Führe die Anfrage aus
    response <- POST(url,
                     add_headers("Content-Type" = "application/json",
                                 "Authorization" = paste("Bearer", OPENAI_API_KEY)),
                     body = toJSON(payload
                                   , pretty = TRUE
                                   , auto_unbox = TRUE # required, else prompt will be a list, but a string is required
                                   )
                     )

  # Überprüfe die Antwort
    if (http_type(response) == "application/json") {
      content <- data.frame(content(response, "parsed"))
      print(content$data.revised_prompt)
      # browseURL(content$data.url)
      
      temp = tempfile(fileext = ".png")
      download.file(content$data.url, destfile = temp, mode = "wb") # "test.png"
      #too slow
        # img = readPNG(temp)
        # grid::grid.raster(img) 
      img <- magick::image_read(temp)
      plot(img)
  
  
      
    } else {
      print("Error when retrieving the data.")
    }



#---------------------------------#
## Code Generation & Execution ####
#---------------------------------#

#Generate R Code by GPT and execute it locally on the fly

g = function(prompt = NULL, apiKey= Sys.getenv("openai_secret_key"), reset = FALSE, rcoder=TRUE, execute = TRUE) { #, log.file=FALSE
  
#Logging console output
  #if(log.file){
    #log = file("logfile.txt") 
    #sink(log, append = TRUE, type = "output")
    #sink(log, append = TRUE, type = "message")
  #}
  
  
#Prompt Engineering: Specify output format/content-type
if(rcoder) {
  prompt.embedded = paste(
"You are an R coding assistant. For the rest of this conversation, return R code only.
Do not include anything else such as extra characters or comments.
DO NOT install any packages but assume I already have them installed.
Prompt: ",  substr(prompt,2, nchar(prompt)))
} else { prompt.embedded = substr(prompt,2, nchar(prompt))}


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
  if(!grepl("[a-z]\\(", print)) print = paste0("# ", print)


  #execute replied R Code directly
  if(execute) {
    #Send prompt to console
      rstudioapi::sendToConsole(paste0("# ",prompt), execute = TRUE)
  
    #Send the R comments to the console
      rstudioapi::sendToConsole(code = print %>%
                              stringr::str_remove('^\n') %>%
                              stringr::str_remove('^R') %>%
                              stringr::str_remove_all('\\`\\`\\`\\{r\\}') %>%
                              stringr::str_remove_all('\\`\\`\\`') %>%
                              stringr::str_trim(side = 'left'),
                              execute = TRUE, echo = TRUE)
  } else {
    #Send prompt to console
      rstudioapi::sendToConsole(paste0("# ",prompt), execute = TRUE)
  
    #Send the R comments to the console
      rstudioapi::sendToConsole(code = print %>%
                              stringr::str_remove('^\n') %>%
                              stringr::str_remove('^R') %>%
                              stringr::str_remove_all('\\`\\`\\`\\{r\\}') %>%
                              stringr::str_remove_all('\\`\\`\\`') %>%
                              stringr::str_trim(side = 'left'),
                              execute = execute, echo = TRUE)
  }




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

t = function(prompt = NULL) {
  g(prompt, rcoder=FALSE, execute=FALSE)
}


t("Was ist Data Governance?")


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





#---------------------------------------------------------------#
## RAG - Retrieval Augmented Generation (by vector database) ####
#---------------------------------------------------------------#

  install.packages("pdftools")
  library(pdftools)
  
  library(httr) # contains: content() -> Extract content from a request
  
  pdf_content <- pdf_text(r"(<Filename>)")
  
  #Check how to split paragraphs
    # strsplit(pdf_content[7], "\n\n\n")
  
  # Actual splitting of paragraphs
    doc_snippets = lapply(pdf_content, function(x) strsplit(x, "\n\n\n"))
    doc_snippets = unlist(a)
  
    doc_snippets = doc_snippets[1:324]
  
    # doc_snippets[1]



  url.completions = "https://api.openai.com/v1/completions"
  url.embeddings = "https://api.openai.com/v1/embeddings"
  url.fine_tune = "https://api.openai.com/v1/fine-tunes"
  url.chat_completions = "https://api.openai.com/v1/chat/completions"

  gpt3_single_embedding = function(input
                                 , model = 'text-embedding-ada-002'
                                 ){
    require(httr)
  
    parameter_list = list(model = model
                          , input = input)
  
    request_base = httr::POST(url = url.embeddings
                              , body = parameter_list
                              , httr::add_headers(Authorization = paste("Bearer", openai_secret_key))
                              , encode = "json")
  
    if(request_base$status_code != 200){
      warning(paste0("Request completed with error. Code: ", request_base$status_code
                     , ", message: ", content(request_base)$error$message))
    }
  
    output_base = httr::content(request_base)
  
    # embedding_raw = to_numeric(unlist(output_base$data[[1]]$embedding))
    embedding_raw = as.numeric(unlist(output_base$data[[1]]$embedding))
  
  
    return(embedding_raw)
  
  }


  # receive embeddings
  doc_embeddings = gpt3_single_embedding(input = doc_snippets[17])

  
  
  
  
  
  
#---------------------#
# openai - package ####
#---------------------#
  
  
  #----------------------#
  ## Image Generation ####
  #----------------------#  
    
  
  prompt = "Electrons orbiting an atomic nucleus in photorealistic style" #
  
  prompt =  "A field of wheat where people of different cultures stand and talk in their traditional clothes"
  
  library(openai)
  
  size = "1024x1024" # c("256x256", "512x512", "1024x1024")
  
  url = openai::create_image(prompt = prompt,
                         n = 1,
                         size = size,
                         openai_api_key = OPENAI_API_KEY)
  
  filename = paste(r"(C:\Users\sress\Downloads)", "ShinyTron2.png", sep = "/")
  
  download.file(url$data[[1]], filename, mode = "wb")

