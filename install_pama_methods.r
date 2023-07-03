# Not working! Is just copying the files -> no INSTALLATION performed ----
  install.packages(r"(C:\Users\sress\Downloads\PaMaTo-main.zip)", repos = NULL, type = "win.binary")
  library("pama")


  # OR
  

# Working: download file and install ----
  if(!require("devtools")) install.packages("devtools")
  library(devtools)
  destination = paste0(getwd(), "/PaMaTo-main.zip")
  download.file("https://github.com/SimonRess/PaMaTo/archive/refs/heads/main.zip", destination)
  
  unzip_path = paste0(getwd(), "/PaMaTo-main")
  unzip(r"(C:\Users\sress\Downloads\PaMaTo-main.zip)", exdir = dirname(unzip_path))
  
  install(unzip_path)
  library("pama")
  
  
  # OR

  
# Working: Install from GitHub (I) ----
  if(!require("remotes")) install.packages("remotes")
  library("remotes")
  install_github("https://github.com/SimonRess/PaMaTo/")
  library("pama")

  
  # OR

  
# Working: Install from GitHub (II) ----
  if(!require("devtools")) install.packages("devtools")
  library(devtools)
  install_github("https://github.com/SimonRess/PaMaTo/")
  library("pama")

